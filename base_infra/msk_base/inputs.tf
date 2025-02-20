variable "msk_identifier" {
  type        = string
  default     = "ac-shopping-msk-cluster"
  description = "Resource identifier"
}

variable "vpc_id" {
  default = ""
}

variable "kafka_version" {
  type    = string
  default = "2.8.1"
}

variable "number_of_broker_nodes" {
  default = 3
  type    = number
}
variable "instance_type" {
  type    = string
  default = "kafka.t3.small"
}
variable "ebs_volume_size" {
  default = 25
  type    = number
}
variable "client_subnets" {
  type = list(string)
}

variable "cloud_watch_logs_enabled" {
  default = true
}
variable "log_group_name" {
  default = "ac-shopping-msk"
}


variable "tags" {
  type        = map(string)
  description = "Additional resource tags"
  default     = {}
}

variable "msk_configuration" {
  default     = <<PROPERTIES
                auto.create.topics.enable=true
                default.replication.factor=3
                min.insync.replicas=2
                num.io.threads=8
                num.network.threads=5
                num.partitions=1
                num.replica.fetchers=2
                message.max.bytes=104857600
                replica.lag.time.max.ms=30000
                socket.receive.buffer.bytes=102400
                socket.request.max.bytes=104857600
                socket.send.buffer.bytes=102400
                unclean.leader.election.enable=true
                zookeeper.session.timeout.ms=18000
                PROPERTIES
  description = "MSK configuration"
  type        = string
}

variable "enhanced_monitoring" {
  description = "Specify the desired enhanced MSK CloudWatch monitoring level to one of three monitoring levels: DEFAULT, PER_BROKER, PER_TOPIC_PER_BROKER or PER_TOPIC_PER_PARTITION. See [Monitoring Amazon MSK with Amazon CloudWatch](https://docs.aws.amazon.com/msk/latest/developerguide/monitoring.html)."
  type        = string
  default     = "DEFAULT"
}

variable "include_default_egress_rule" {
  default     = false
  type        = bool
  description = "Allow all ports outbound to egress cidrs"
}
variable "egress_cidrs" {
  type = list(string)
}

variable "include_default_ingress_rule" {
  default     = true
  type        = bool
  description = "Allow all ports inbound to allowed cidrs"
}

variable "allowed_cidrs" {
  type = list(string)
}

