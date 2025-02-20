#!/bin/bash
APPLICATION_CONFIG=$(envsubst < "/tmp/application.tpl")
envsubst < "/tmp/application.tpl" > /app/application.yml
# JSON=$(curl ${ECS_CONTAINER_METADATA_URI}/task)
# echo $JSON
# TASK=$(echo $JSON | jq -r '.Containers[0].Networks[0].IPv4Addresses[0]')
# echo $TASK
echo "===> Launching AKHQ"
./akhq