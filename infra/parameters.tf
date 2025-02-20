# resource "aws_ssm_parameter" "msk_secret" {
#   name        = local.secret_string_ssm
#   description = "The parameter description"
#   type        = "String"
#   value       = jsonencode({ "username" = "admin", "password" = "pass" })
# }

# data "aws_ssm_parameter" "msk_secret_string" {
#   name       = local.secret_string_ssm
#   depends_on = [aws_ssm_parameter.msk_secret]
# }

# resource "aws_msk_scram_secret_association" "msk_authentication" {
#   cluster_arn     = module.msk.cluster_arn
#   secret_arn_list = [aws_secretsmanager_secret.msk_authentication.arn]

#   depends_on = [aws_secretsmanager_secret_version.msk_authentication]
# }

# resource "aws_secretsmanager_secret" "msk_authentication" {
#   name       = "AmazonMSK_${local.common.service_name}-${var.account_type}"
#   kms_key_id = module.msk.kms_arn
#   tags = merge(
#     {
#       Name = "AmazonMSK_${local.common.service_name}-${var.account_type}"
#     },
#     {}
#   )
# }

# resource "aws_secretsmanager_secret_version" "msk_authentication" {
#   secret_id     = aws_secretsmanager_secret.msk_authentication.id
#   secret_string = data.aws_ssm_parameter.msk_secret_string.value
# }

# resource "aws_secretsmanager_secret_policy" "msk_authentication" {
#   secret_arn = aws_secretsmanager_secret.msk_authentication.arn
#   policy = jsonencode(
#     {
#       "Version" : "2012-10-17",
#       "Statement" : [
#         {
#           "Sid" : "AWSKafkaResourcePolicy",
#           "Effect" : "Allow",
#           "Principal" : {
#             "Service" : "kafka.amazonaws.com"
#           },
#           "Action" : "secretsmanager:getSecretValue",
#           "Resource" : "${aws_secretsmanager_secret.msk_authentication.arn}"
#         }
#       ]
#   })
# }
