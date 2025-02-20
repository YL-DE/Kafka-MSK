import boto3
import json
import sys

output_json = None
msk_arn = sys.argv[1]
endpoint = sys.argv[2]
region_name = "ap-southeast-2"
client = boto3.client("kafka", region_name=region_name)
response = client.list_nodes(ClusterArn=msk_arn)
for node_info in response["NodeInfoList"]:
    if "ZookeeperNodeInfo" not in node_info:
        endpoint = "b" + endpoint[1:]
    if node_info.get("BrokerNodeInfo", {}).get("Endpoints", [""])[0] == endpoint:
        output_json = json.dumps({"ip": node_info["BrokerNodeInfo"]["ClientVpcIpAddress"]})
        break
    elif node_info.get("ZookeeperNodeInfo", {}).get("Endpoints", [""])[0] == endpoint:
        output_json = json.dumps({"ip": node_info["ZookeeperNodeInfo"]["ClientVpcIpAddress"]})
        break

if output_json:
    print(output_json)
else:
    print(json.dumps({"ip": None}))
