locals {
  secret_string_ssm = "/ac-shopping/msk/secret_string"
  secret_policy_account_ids = {
    nonprod = ["721495903582"],
    prod    = ["721495903582"]
  }

  vpc_endpoints_account_ids = {
    nonprod = ["721495903582"],
    prod    = ["721495903582"]
  }

  common = {
    service_name = var.app_name
    application  = "ac-shopping-msk"
    owner        = "DE"
    costCentre   = "DATA"
    createdBy    = "DE"

  }
  account_config = {
    nonprod = {
      vpc_name               = "ac-shopping-vpc" # yl
      ebs_volume_size        = 20
      number_of_broker_nodes = 3
      instance_type          = "kafka.t3.small"
      managedBy              = "datasquad645@gmail.com"
      notification_email     = "datasquad645@gmail.com"
      kafka_bootstrap_ssm    = "/ac-shopping-kafka/kafka_bootstrap_list"
      kafka_user_ssm         = "/ac-shopping-kafka/kafka_user"
      kafka_password_ssm     = "/ac-shopping-kafka/kafka_password"
    }
  }
}
