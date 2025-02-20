output "cluster_id" {
  value = aws_msk_cluster.cluster.id
}

output "cluster_name" {
  value = aws_msk_cluster.cluster.cluster_name
}

output "cluster_arn" {
  value = aws_msk_cluster.cluster.arn
}

output "security_group_id" {
  value = aws_security_group.cluster.id

}

output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value       = aws_msk_cluster.cluster.bootstrap_brokers_tls
}

output "bootstrap_brokers_sasl_scram" {
  description = "TLS connection host:port pairs"
  value       = aws_msk_cluster.cluster.bootstrap_brokers_sasl_scram
}

output "zookeeper_connect_string" {
  value = aws_msk_cluster.cluster.zookeeper_connect_string
}

output "kms_alias_name" {
  value = aws_kms_alias.msk_key_alias.name
}

output "kms_arn" {
  value = aws_kms_key.msk_kms_key.arn
}
