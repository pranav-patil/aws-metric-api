import boto3
import os
import time

page_size = 50
MAX_ITEMS = 51
TOTAL_RESULTS = 0
ENABLE_RAW_PRINT = False # Change to 'True' if the raw query results are desired

query_response = None
paginator = None
HEADERS = None

def reset_globals():
    global page_size, MAX_ITEMS, query_response, paginator, HEADERS, TOTAL_RESULTS
    page_size = 50
    query_response = None
    paginator = None
    HEADERS = None
    TOTAL_RESULTS = 0

def fetch_metric(start, stop, limit, order):
    if start == None:
        start = 0
    if stop == None:
        stop = time.time()
    if limit == None:
        limit = 50
    if order == None:
        order = "Ascending"

    athena_client = boto3.client("athena")
    athena_workgroup = os.environ['ATHENA_WORKGROUP']
    named_query_ids = athena_client.list_named_queries(WorkGroup=athena_workgroup).get("NamedQueryIds")
    named_query = get_metric_table_named_query(athena_client, named_query_ids)
    start_timestamp = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(int(start)))
    stop_timestamp = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(int(stop)))

    query_string = (
        named_query['NamedQuery']['QueryString'] + (
        " WHERE cast(ts as timestamp) >= timestamp '{}' AND " +
        "cast(ts as timestamp) <= timestamp '{}' ORDER BY ts")
        ).format(start_timestamp, stop_timestamp)

    if order == "Descending":
        query_string = query_string + "DESC;"
    else:
        query_string = query_string + ";"

    reset_globals()

    global query_response, paginator

    query_response = athena_client.start_query_execution(
        QueryString=query_string,
        QueryExecutionContext={"Database": named_query['NamedQuery']['Database']},
        ResultConfiguration={
            "OutputLocation": ("s3://" + athena_workgroup + "-metric-data/output/")}
    )
    query_execution_id = query_response["QueryExecutionId"]
    success = check_query_execution(athena_client, query_execution_id, 10)
    if not success:
        return "Error: Query execution failed."

    set_total_results(athena_client.get_query_results(QueryExecutionId = query_execution_id))

    global page_size
    page_size = int(limit) + 1

    paginator = athena_client.get_paginator("get_query_results")
    page_iterator = cursor_pagination()

    for page in page_iterator:
        if ENABLE_RAW_PRINT:
            return page
        return get_formatted_data(page)

    athena_client.close()

def fetch_metric_next_page(next_token):
    global page_size
    page_size -= 1
    formatted_next_token = next_token.replace(" ", "+")
    page_iterator = cursor_pagination(formatted_next_token)
    for page in page_iterator:
        if ENABLE_RAW_PRINT:
            return page
        return get_formatted_data(page)

def get_formatted_data(page):
    next_token = None
    if page.get("NextToken"):
        next_token = page["NextToken"]

    if len(page["ResultSet"]["Rows"]) == 0:
        return "No more results."

    page = set_headers(page)
    del page["UpdateCount"]
    del page["ResponseMetadata"]
    del page["ResultSet"]["ResultSetMetadata"]

    rows = page["ResultSet"]["Rows"]

    new_rows = []
    for data_dict in rows:
        data = []
        for value_dict in data_dict["Data"]:
            data.append(value_dict["VarCharValue"])
        new_rows.append(data)


    new_rows.insert(0, HEADERS)
    if next_token:
        return {"Total Results": TOTAL_RESULTS, "Number of Rows": len(new_rows)-1, "Data": new_rows, "NextToken": next_token}
    else:
        return {"Total Results": TOTAL_RESULTS, "Number of Rows": len(new_rows)-1, "Data": new_rows}

def empty_metric_data_bucket():
    s3 = boto3.resource('s3')
    bucket_name = os.environ['STACK_NAME'] + "-metric-data-bucket"
    bucket = s3.Bucket(bucket_name)
    bucket.objects.all().delete()
    return "All objects from bucket deleted."

def set_headers(page):
    global HEADERS
    if not HEADERS == None:
        return page
    HEADERS = []
    the_headers = page["ResultSet"]["Rows"][0]["Data"]
    for first_row in the_headers:
        HEADERS.append(first_row['VarCharValue'])
    del page["ResultSet"]["Rows"][0]
    return page

def set_total_results(results):
    global TOTAL_RESULTS
    TOTAL_RESULTS = len(results["ResultSet"]["Rows"]) - 1

def check_query_execution(athena_client, query_execution_id, max_execution=5):
    state = 'RUNNING'

    while max_execution > 0 and state in ['RUNNING', 'QUEUED']:
        max_execution = max_execution - 1
        response = athena_client.get_query_execution(QueryExecutionId=query_execution_id)

        if 'QueryExecution' in response and \
                'Status' in response['QueryExecution'] and \
                'State' in response['QueryExecution']['Status']:

            state = response['QueryExecution']['Status']['State']

            if state == 'SUCCEEDED':
                return True
            elif state == 'FAILED':
                raise RuntimeError(response['QueryExecution']['Status']['StateChangeReason'])

        time.sleep(3)

    return False


def get_metric_table_named_query(athena_client, named_query_ids):
    for query_id in named_query_ids:
        named_query = athena_client.get_named_query(NamedQueryId=query_id)
        query_name = named_query['NamedQuery']['Name']

        if 'select_all_metric_data' in query_name:
            return named_query
    return None

def cursor_pagination(next_token = None):
    if next_token == None:
        pagination_config = {"MaxItems": MAX_ITEMS, "PageSize": page_size}
    else:
        pagination_config = {
            "MaxItems": MAX_ITEMS,
            "PageSize": page_size,
            "StartingToken": next_token
        }
    page_iterator = paginator.paginate(
        QueryExecutionId=query_response["QueryExecutionId"],
        PaginationConfig=pagination_config
    )
    return page_iterator
