data "aws_caller_identity" "current" {} # get current aws account info

resource "aws_msk_cluster" "cluster" {
  cluster_name           = var.msk_identifier
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_broker_nodes
  broker_node_group_info {
    instance_type   = var.instance_type
    client_subnets  = var.client_subnets
    security_groups = [aws_security_group.cluster.id]
    storage_info {
      ebs_storage_info {
        volume_size = var.ebs_volume_size
      }
    }
  }
  enhanced_monitoring = var.enhanced_monitoring

  client_authentication {
    unauthenticated = true
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.msk_kms_key.arn
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  configuration_info {
    arn      = aws_msk_configuration.msk_config.arn
    revision = aws_msk_configuration.msk_config.latest_revision
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = var.cloud_watch_logs_enabled
        log_group = var.log_group_name
      }
    }
  }

  tags = merge(var.tags, { Name = "${var.msk_identifier}" })
}

resource "aws_msk_configuration" "msk_config" {
  kafka_versions    = [var.kafka_version]
  name              = "${var.msk_identifier}-msk-config"
  server_properties = var.msk_configuration

}

resource "aws_security_group" "cluster" {
  name        = "${var.msk_identifier}-sg"
  description = "Container access for: ${var.msk_identifier}"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.msk_identifier}-sg"
  })
}

resource "aws_security_group_rule" "cluster_default_egress" {
  count = var.include_default_egress_rule == true ? 1 : 0
  type  = "egress"

  security_group_id = aws_security_group.cluster.id

  protocol  = "tcp"
  from_port = 0
  to_port   = 0

  cidr_blocks = var.egress_cidrs
}

resource "aws_security_group_rule" "cluster_default_ingress_sasl" {
  count = var.include_default_ingress_rule == true ? 1 : 0

  type = "ingress"

  security_group_id = aws_security_group.cluster.id

  protocol  = "tcp"
  from_port = 9096
  to_port   = 9096

  cidr_blocks = var.allowed_cidrs
}

resource "aws_security_group_rule" "cluster_default_ingress_tls" {
  count = var.include_default_ingress_rule == true ? 1 : 0

  type = "ingress"

  security_group_id = aws_security_group.cluster.id

  protocol  = "tcp"
  from_port = 9094
  to_port   = 9094

  cidr_blocks = var.allowed_cidrs
}

resource "aws_security_group_rule" "cluster_default_ingress_iam" {
  count = var.include_default_ingress_rule == true ? 1 : 0

  type = "ingress"

  security_group_id = aws_security_group.cluster.id

  protocol  = "tcp"
  from_port = 9098
  to_port   = 9098

  cidr_blocks = var.allowed_cidrs
}

resource "aws_security_group_rule" "cluster_default_ingress_zoo" {
  count = var.include_default_ingress_rule == true ? 1 : 0

  type = "ingress"

  security_group_id = aws_security_group.cluster.id

  protocol  = "tcp"
  from_port = 2181
  to_port   = 2181

  cidr_blocks = var.allowed_cidrs
}
