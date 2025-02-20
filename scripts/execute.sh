#!/bin/bash
set -eou pipefail

echo "APP_NAME is ${APP_NAME} and ACCOUNT_TYPE is ${ACCOUNT_TYPE}"

die() {
  echo "$2"
  exit "$1"
}

execute_terraform() {
  if which terraform1 2>/dev/null; then
    terraform1 $@
  else
    terraform $@
  fi
}

OPERATION=$1
PLAN_FILE="${APP_NAME}-${ACCOUNT_TYPE}.plan"

if [[ $# != 1 ]]; then
  echo "Usage $(basename "${0}") <plan|apply|destroy>"
  exit 101
fi
STATE_STORE_BUCKET_NAME="${TFSTATE_BUCKET_NAME}"
STATE_STORE_BUCKET_KEY_NAME="${APP_NAME}-${ACCOUNT_TYPE}/${ACCOUNT_TYPE}.tfstate"

export TF_VAR_app_name="${APP_NAME}"
export TF_VAR_cluster_name="${APP_NAME}"
export TF_VAR_account_type="$ACCOUNT_TYPE"
export TF_VAR_environment="${ACCOUNT_TYPE}"
export TF_VAR_aws_region="${AWS_REGION}"

cd infra

execute_terraform init \
  -no-color \
  -reconfigure \
  -backend-config "region=${AWS_REGION}" \
  -backend-config "bucket=${STATE_STORE_BUCKET_NAME}" \
  -backend-config "key=${STATE_STORE_BUCKET_KEY_NAME}"

case $OPERATION in
  test)
    echo "all ok to proceed and test"
    ;;
  plan)
    execute_terraform plan \
      -no-color \
      -parallelism=1000 \
      -out "$PLAN_FILE"
    ;;
  apply)
    execute_terraform apply \
      -no-color \
      -auto-approve \
      -input=false \
      -parallelism=1000
    ;;
  destroy)
    execute_terraform destroy \
      -no-color \
      -auto-approve
    ;;
  *)
    die 102 "Unknown OPERATION: $OPERATION"
    ;;
esac