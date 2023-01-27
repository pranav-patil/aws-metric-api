import boto3
import json
from datetime import datetime
import time
import sys
import argparse
from flatten_json import flatten
import exrex

firehose_name = ""
firehose_client = ""
sleep_time_msec = 500
aws_region = "us-east-1"
def generate_app_logs(firehose_stream):
    payload = {
        "version": 2,
        "appname": exrex.getone('[A-Z][a-z]{9}'),
        "user": "1231313231",
        "message": exrex.getone('[a-z]{200}'),
        "ts": datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S"),
        "tenant_id": "4324234242",
        "status": "success",
        "type": "configuration"
    }
    record_data = flatten(payload)
    print(firehose_stream)
    firehose_client.put_record(DeliveryStreamName=firehose_stream,
                               Record={
                                   'Data': json.dumps(record_data)
                               }
                               )

def main():
    """
    Main entrypoint.
    """
    parser = argparse.ArgumentParser(description='Send the metric records to kinesis data stream.\
                                     This assumes that AWS_* vars are set')

    parser.add_argument('-t', '--time', type=str, required=True,
                        help="time in msec")
    parser.add_argument('-k', '--kinesis', required=True, help="demo name")
    parser.add_argument('-r', '--region', required=True, help="AWS region")
    arg = parser.parse_args()
    global firehose_name
    firehose_name = arg.kinesis
    global firehose_client
    firehose_client = boto3.client('firehose', region_name=arg.region)
    global sleep_time_msec
    sleep_time_msec = arg.time
    global aws_region
    aws_region = arg.region
    sleep_time = int(sleep_time_msec)/1000
    while True:
        generate_app_logs(arg.kinesis + "-metric-data-firehose")
        time.sleep(sleep_time)


if __name__ == '__main__':
    sys.exit(main())
