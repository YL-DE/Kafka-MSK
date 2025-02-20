# App defaults
ACCOUNT_TYPE ?= nonprod
APP_NAME ?= ac-shopping-msk
AWS_REGION ?= ap-southeast-2
AWS_DEFAULT_REGION ?= $(AWS_REGION)
TFSTATE_BUCKET_NAME ?= ac-shopping-tf-state
KAFKA_SASL_MECHANISM ?= SCRAM-SHA-512
KAFKA_SECURITY_PROTOCOL ?= SASL_SSL
KAFKA_SSL_TRUSTSTORE_LOCATION ?= /usr/local/kafka_2.13-2.8.0/bin/kafka.client.truststore.jks
KAFKA_SSL_TRUSTSTORE_LOCATION ?= /usr/local/kafka_2.13-2.8.0/bin/kafka.client.truststore.jks
KAFKA_SSL_TRUSTSTORE_PASSWORD ?= changeit
ACCOUNT_NUMBER := $(shell aws sts get-caller-identity | python3 -c "import sys, json; print(json.load(sys.stdin)['Account'])")
CONTAINER_FOLDER ?= app/containers

# Export variables into child processes
.EXPORT_ALL_VARIABLES:

plan-infra:
	pip3 install boto3
	bash scripts/execute.sh plan
	
deploy-infra:
	pip3 install boto3
	bash scripts/execute.sh apply

destroy-infra:
	bash scripts/execute.sh destroy

package-artefact:
	bash scripts/package-artefact.sh "infra scripts app entrypoint.sh Dockerfile Makefile"

plan-topics:
	bash scripts/topic.sh plan

apply-topics:
	bash scripts/topic.sh apply
