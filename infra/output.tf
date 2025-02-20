output "bootstrap_brokers" {
  value = module.msk.bootstrap_brokers_sasl_scram
}

output "zookeeper_details" {
  value = module.msk.zookeeper_connect_string
}

output "msk_vpce" {
  value = "${aws_vpc_endpoint_service.msk_vpc_endpoint.*.service_name}"
}