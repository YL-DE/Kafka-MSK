#!/bin/bash
set -eou pipefail

EXECUTION_STAGE="${1:-}"

if [ -z "${EXECUTION_STAGE}" ]; then
    echo "Parameter 2 cannot be empty. Must specify plan or apply"
fi

echo "Getting Secrets from AWS Secret Manager: $AWS_SECRET_MANAGER_NAME from region: ${AWS_REGION}"
SECRET_MANAGER=$(aws secretsmanager get-secret-value --secret-id $AWS_SECRET_MANAGER_NAME --region ${AWS_REGION})
export KAFKA_SASL_JAAS_USERNAME=$(echo "$SECRET_MANAGER" | jq -r '.SecretString' | jq -r '.username')
export KAFKA_SASL_JAAS_PASSWORD=$(echo "$SECRET_MANAGER" | jq -r '.SecretString' | jq -r '.password')

echo "Using the topics from: app/config/topics-state-${ACCOUNT_TYPE}.yaml"
partition_count=$(echo "${KAFKA_BOOTSTRAP_SERVERS}" | awk -F"," '{print NF}')
echo "Partition Count: $partition_count"
sed -i "s/^\( *partitions:  *\)[^ ]*\(.*\)*$/\1${partition_count}\2/" "app/config/topics-state-${ACCOUNT_TYPE}.yaml"
echo "Starting Kafka Validate"
kafka-gitops -f "app/config/topics-state-${ACCOUNT_TYPE}.yaml" validate
echo "Starting Kafka $EXECUTION_STAGE"
kafka-gitops -f "app/config/topics-state-${ACCOUNT_TYPE}.yaml" --skip-acls "${EXECUTION_STAGE}"