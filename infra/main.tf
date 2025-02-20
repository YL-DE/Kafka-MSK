data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc" {
  tags = {
    Name = local.account_config[var.account_type].vpc_name
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Name = "*private*"
  }
}

data "aws_security_group" "msk_security_group" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Name = "*msk*"
  }

  depends_on = [module.msk]
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/msk/cluster/${local.common.service_name}-${var.account_type}"
  retention_in_days = 3
  tags = merge(
    {
      Name = "/msk/cluster/${local.common.service_name}-${var.account_type}"
    },
    {}
  )
}

module "msk" {
  source = "../base_infra/msk_base"
  # allowed_cidrs            = ["10.0.0.0/8"]
  allowed_cidrs            = ["0.0.0.0/0"]
  egress_cidrs             = ["0.0.0.0/0"]
  msk_identifier           = "${local.common.service_name}-${var.account_type}"
  vpc_id                   = data.aws_vpc.vpc.id
  client_subnets           = data.aws_subnets.private_subnets.ids
  cloud_watch_logs_enabled = true
  log_group_name           = aws_cloudwatch_log_group.log_group.name
  ebs_volume_size          = local.account_config[var.account_type].ebs_volume_size
  number_of_broker_nodes   = local.account_config[var.account_type].number_of_broker_nodes
  instance_type            = local.account_config[var.account_type].instance_type
  tags = merge(
    {
      "Name" = "${local.common.service_name}-${var.account_type}-msk"
    },
    {}
  )
}

# Create a VPC endpoint for RDS
resource "aws_vpc_endpoint" "rds_endpoint" {
  vpc_id            = data.aws_vpc.vpc.id
  service_name      = "com.amazonaws.ap-southeast-2.rds"
  vpc_endpoint_type = "Interface" # You can use "Gateway" if applicable

  subnet_ids = data.aws_subnets.private_subnets.ids

  security_group_ids = [data.aws_security_group.msk_security_group.id]

  private_dns_enabled = true # Enable/disable private DNS resolution
  depends_on          = [module.msk]
}

# #### NLB ###
# resource "aws_lb" "msk_nlb" {
#   count                            = local.account_config[var.account_type].number_of_broker_nodes
#   name                             = "${local.common.service_name}-${var.account_type}-nlb-${count.index}"
#   internal                         = true
#   load_balancer_type               = "network"
#   subnets                          = data.aws_subnets.private_subnets.ids
#   enable_cross_zone_load_balancing = true
#   tags = merge(
#     {
#       "Name" = "${local.common.service_name}-${var.account_type}-nlb-${count.index}"
#     },
#     {}
#   )
# }

# resource "aws_lb_listener" "msk_nlb_listener" {
#   count             = local.account_config[var.account_type].number_of_broker_nodes
#   load_balancer_arn = aws_lb.msk_nlb[count.index].arn
#   protocol          = "TCP"
#   port              = "9096"
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.msk_nlb_tg[count.index].arn
#   }
#   tags = {}
# }


# resource "aws_lb_listener" "msk_nlb_listener_node_exporter" {
#   count             = local.account_config[var.account_type].number_of_broker_nodes
#   load_balancer_arn = aws_lb.msk_nlb[count.index].arn
#   protocol          = "TCP"
#   port              = "11002"
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.msk_nlb_tg_node_exporter[count.index].arn
#   }
#   tags = {}
# }

# resource "aws_lb_target_group" "msk_nlb_tg" {
#   count       = local.account_config[var.account_type].number_of_broker_nodes
#   name        = "${local.common.service_name}-${var.account_type}-tg-${count.index}"
#   port        = 9096
#   protocol    = "TCP"
#   vpc_id      = data.aws_vpc.vpc.id
#   target_type = "ip"

#   depends_on = [
#     aws_lb.msk_nlb
#   ]
#   lifecycle {
#     create_before_destroy = true
#   }
#   tags = merge(
#     {
#       "Name" = "${local.common.service_name}-${var.account_type}-tg-${count.index}"
#     },
#     {}
#   )
# }


# resource "aws_lb_target_group" "msk_nlb_tg_node_exporter" {
#   count       = local.account_config[var.account_type].number_of_broker_nodes
#   name        = "${local.common.service_name}-${var.account_type}-tg-${count.index}-node"
#   port        = 11002
#   protocol    = "TCP"
#   vpc_id      = data.aws_vpc.vpc.id
#   target_type = "ip"

#   depends_on = [
#     aws_lb.msk_nlb
#   ]
#   lifecycle {
#     create_before_destroy = true
#   }
#   tags = merge(
#     {
#       "Name" = "${local.common.service_name}-${var.account_type}-tg-${count.index}"
#     },
#     {}
#   )
# }

# resource "aws_lb_target_group_attachment" "msk_nlb_tg_attachment" {
#   count            = local.account_config[var.account_type].number_of_broker_nodes
#   target_group_arn = aws_lb_target_group.msk_nlb_tg[count.index].arn
#   target_id        = data.external.msk_broker_ip[count.index].result["ip"]
#   port             = 9096
# }

# resource "aws_lb_target_group_attachment" "msk_nlb_tg_attachment_node_exporter" {
#   count            = local.account_config[var.account_type].number_of_broker_nodes
#   target_group_arn = aws_lb_target_group.msk_nlb_tg_node_exporter[count.index].arn
#   target_id        = data.external.msk_broker_ip[count.index].result["ip"]
#   port             = 11002
# }

# data "external" "msk_broker_ip" {
#   count   = local.account_config[var.account_type].number_of_broker_nodes
#   program = ["python3", "${path.module}/scripts/get_broker_ip.py", module.msk.cluster_arn, trimsuffix(split(",", module.msk.bootstrap_brokers_sasl_scram)[count.index], ":9096"), var.aws_region]
# }

# resource "aws_vpc_endpoint_service" "msk_vpc_endpoint" {
#   count                      = local.account_config[var.account_type].number_of_broker_nodes
#   acceptance_required        = false
#   network_load_balancer_arns = [aws_lb.msk_nlb[count.index].arn]
#   allowed_principals         = ["*"]
#   tags = merge(
#     {
#       "Name" = "${local.common.service_name}-${var.account_type}-vpces-${count.index}"
#     },
#     {}
#   )
#   depends_on = [
#     aws_lb.msk_nlb
#   ]
# }

# # data "aws_route53_zone" "kafka_private_hosted_zone" {
# #   name         = local.account_config[var.account_type].kafka_route53_hosted_zone
# #   private_zone = true
# #   vpc_id       = data.aws_vpc.vpc.id
# # }

# # resource "aws_route53_record" "route53-record" {
# #   count   = local.account_config[var.account_type].number_of_broker_nodes
# #   zone_id = data.aws_route53_zone.kafka_private_hosted_zone.zone_id
# #   name    = trimsuffix(split(",", module.msk.bootstrap_brokers_sasl_scram)[count.index], ":9096")
# #   type    = "A"
# #   alias {
# #     name                   = aws_lb.msk_nlb[count.index].dns_name
# #     zone_id                = aws_lb.msk_nlb[count.index].zone_id
# #     evaluate_target_health = true
# #   }
# # }

# data "external" "zookeeper_ip" {
#   count   = local.account_config[var.account_type].number_of_broker_nodes
#   program = ["python3", "${path.module}/scripts/get_broker_ip.py", module.msk.cluster_arn, trimsuffix(split(",", module.msk.zookeeper_connect_string)[count.index], ":2181"), var.aws_region]
# }

# resource "aws_route53_record" "zookeeper_route53_record" {
#   count   = local.account_config[var.account_type].number_of_broker_nodes
#   zone_id = data.aws_route53_zone.kafka_private_hosted_zone.zone_id
#   name    = trimsuffix(split(",", module.msk.zookeeper_connect_string)[count.index], ":2181")
#   type    = "A"
#   ttl     = "300"
#   records = [data.external.zookeeper_ip[count.index].result["ip"]]
# }
