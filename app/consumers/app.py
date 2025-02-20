import time
import os
from kafka import KafkaConsumer
from kafka.errors import KafkaError
from logging import Logger
import pandas
import psycopg2
import boto3
import json

logger = Logger(name="ac_shopping_crm_consumer_logger")

config = {
    "bootstrap_servers": "b-1.acshoppingmsk.yy0lyn.c2.kafka.ap-southeast-2.amazonaws.com:9092,b-2.acshoppingmsk.yy0lyn.c2.kafka.ap-southeast-2.amazonaws.com:9092,b-3.acshoppingmsk.yy0lyn.c2.kafka.ap-southeast-2.amazonaws.com:9092",
    "topics": "ac_shopping_crm.ac_shopping.customer",
    "group_id": "ac_shopping_crm_consumer_group",
}


class Consumer:
    def __init__(self, bootstrap_servers: list, topics: list, group_id: str) -> None:
        self.bootstrap_servers = bootstrap_servers
        self.topics = topics
        self.group_id = group_id
        self.consumer = self.create_consumer()

    def create_consumer(self):
        return KafkaConsumer(
            "ac_shopping_crm.ac_shopping.customer",
            bootstrap_servers=self.bootstrap_servers,
            auto_offset_reset="earliest",
            enable_auto_commit=True,
            group_id=self.group_id,
            key_deserializer=lambda v: v.decode("utf-8"),
            value_deserializer=lambda v: v.decode("utf-8"),
        )

    def consume_message(self):
        try:
            records = []
            while True:
                msg = self.consumer.poll(timeout_ms=1000)
                if msg is None:
                    continue
                self.print_message(msg)
                records.append(msg)
                df = pandas.DataFrame(records)
                df.to_csv("temp.csv", header=True, index=False)
                s3_client = boto3.client("s3")
                s3_client.upload_file("tmp.csv", "ac_shopping_datalake", "ac_shopping_crm/tmp.csv")
                redshift_connection = self.connect_to_redshift(secret_name="redshift_ac_master")
                redshift_connection.autocommit = True
                copy_cmd = """ truncate staging.customer;
                            copy ac_shopping_crm.customer
                            from 's3://ac_shopping_datalake/ac_shopping_crm/tmp.csv'
                            credentials 'aws_iam_role=arn:aws:iam::721495903582:role/redshift-admin'
                            csv
                            delimiter ','
                            ignoreheader 1 """
                upsert_cmd = """
                            delete from ac_shopping_crm.customer
                            where exists(select 1 from staging.customer st where st.customer_id = customer.customer_id);
                            insert into ac_shopping_crm.customer
                            select * from staging.customer"""
                redshift_connection.execute(copy_cmd)
                redshift_connection.execute(upsert_cmd)
                time.sleep(5)
        except KafkaError as error:
            logger.error(error)

    def print_message(self, message: dict):
        for key, value in message.items():
            for item in value:
                logger.info(
                    f"key={item.key}, value={item.value}, topic={item.topic}, partition={item.partition}, offset={item.offset}, ts={item.timestamp}"
                )

    def connect_to_redshift(self,secret_name):
        secret_manager_client = boto3.client(service_name="secretsmanager", region_name='ap-southeast-2')
        get_secret_value_response = secret_manager_client.get_secret_value(SecretId=secret_name)
        connection_credentials = json.loads(get_secret_value_response["SecretString"])
        try:
            redshift_connection = psycopg2.connect(
                host=connection_credentials.get("host"),
                dbname=connection_credentials.get("database"),
                port=connection_credentials.get("port"),
                user=connection_credentials.get("username"),
                password=connection_credentials.get("password"),
            )
        except Exception as e:
            print(e)
            raise e
        return redshift_connection


if __name__ == "__main__":
    consumer = Consumer(
        bootstrap_servers=(
            os.getenv("BOOTSTRAP_SERVERS", config["bootstrap_servers"])
        ).split(","),
        topics=(os.getenv("TOPICS", config["topics"])).split(","),
        group_id=(os.getenv("GROUP_ID", config["group_id"])),
    )
    consumer.consume_message()
