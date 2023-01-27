from collections import namedtuple
from random import choice
from lib.globals import logger, stage
from flask import Flask, jsonify, make_response
from flask import Flask, jsonify, json, request
from werkzeug.exceptions import HTTPException
from helpers import helper
import time

app = Flask(__name__)

@app.route("/")
def hello_from_root():
    return jsonify(message='Hello from root!')


@app.route("/hello")
def hello():
    return jsonify(message='Hello from path!')


@app.route("/metrics", methods=["GET"])
def get_audit_logs():
    args = request.args
    start = args.get('start')
    stop = args.get('stop')
    limit = args.get('limit')
    order = args.get('order')
    next_token = args.get('next_token')
    if next_token:
        return helper.fetch_audit_logs_next_page(next_token)
    return_string = verify_params(start, stop, limit, order)
    if len(return_string) > 0:
        return {
            "statusCode": 416,
            "headers": {"content-type": "application/json"},
            "body": json.dumps({"message": return_string})
        }
    return helper.fetch_audit_logs(start, stop, limit, order)

@app.route("/metrics/clear", methods=["POST"])
def clear_audit_logs():
    return helper.empty_audit_logs_bucket()


@app.errorhandler(HTTPException)
def handle_exception(e):
    print(request.environ['serverless.context'])
    print(request.environ['serverless.event'])
    response = e.get_response()
    response.data = json.dumps({
        "code": e.code,
        "name": e.name,
        "description": e.description,
    })
    response.content_type = "application/json"
    return response

def verify_params(start, stop, limit, order):
    message = ""
    if start == None:
        start = 0
    if stop == None:
        stop = time.time()
    if limit == None:
        limit = 10
    if order == None:
        order = "Ascending"

    start, stop, limit = int(start), int(stop), int(limit)

    if start > stop:
        message = "Stop time should always be more recent than start time. "

    if limit > 2000:
        message = message + "Limit can not be more than 2000."

    if not order == "Ascending" and not order == "Descending":
        message = message + "Order must be 'Ascending' or 'Descending'."

    return message
