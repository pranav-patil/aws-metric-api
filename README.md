<!--
title: 'Serverless Framework Python Flask API on AWS'
description: 'This template demonstrates how to develop and deploy a simple Python Flask API running on AWS Lambda using the traditional Serverless Framework.'
layout: Doc
framework: v2
platform: AWS
language: Python
priority: 2
authorLink: 'https://github.com/serverless'
authorName: 'Serverless, inc.'
authorAvatar: 'https://avatars1.githubusercontent.com/u/13742415?s=200&v=4'
-->

# Serverless Framework Python Flask API on AWS

This template demonstrates how to develop and deploy a simple Python Flask API service running on AWS Lambda using the traditional Serverless Framework.


## Anatomy of the template

This template configures a single function, `api`, which is responsible for handling all incoming requests thanks to configured `http` events. To learn more about `http` event configuration options, please refer to [http event docs](https://www.serverless.com/framework/docs/providers/aws/events/apigateway/). As the events are configured in a way to accept all incoming requests, `Flask` framework is responsible for routing and handling requests internally. The implementation takes advantage of `serverless-wsgi`, which allows you to wrap WSGI applications such as Flask apps. To learn more about `serverless-wsgi`, please refer to corresponding [GitHub repository](https://github.com/logandk/serverless-wsgi). Additionally, the template relies on `serverless-python-requirements` plugin for packaging dependencies from `requirements.txt` file. For more details about `serverless-python-requirements` configuration, please refer to corresponding [GitHub repository](https://github.com/UnitedIncome/serverless-python-requirements).

## Usage

### Prerequisites

In order to package your dependencies locally with `serverless-python-requirements`, you need to have `Python3.8` installed locally. You can create and activate a dedicated virtual environment with the following command:

```bash
python3.8 -m venv ./venv
source ./venv/bin/activate
```

Alternatively, you can also use `dockerizePip` configuration from `serverless-python-requirements`. For details on that, please refer to corresponding [GitHub repository](https://github.com/UnitedIncome/serverless-python-requirements).

## Serverless

Metric API is managed with the [serverless](https://www.serverless.com/) framework and can be deployed, removed or 
run lambda functions locally or in AWS.

Before running any other serverless commands, please run the following command to install the serverless python
dependency management plugin.

    sls plugin install --name=serverless-python-requirements

This only needs to be performed once. The plugin is installed in the `node_modules` directory. If you perform a
 `./gradlew distClean` or clone a new copy of the repository, you will need to install the plugin again.

### Deploy

Deploy the lambda functions, along with their dependencies, to AWS.

    sls deploy --name-prefix=mycluster- --region=us-west-1 \
    --role-arn=arn:aws:iam::376839559555:role/lambda-role-telemetry-collector \
    --stream-arn=arn:aws:dynamodb:us-west-1:376839559555:table/mycluster_device_monitoring_ApplianceStats_ALPHA/stream/2020-10-31T09:04:11.808

### Remove

Remove the lambdas from AWS

    sls remove --name-prefix=mycluster- --region=us-west-1

### Invoke

Invoke the specified function deployed in AWS.

    sls invoke --name-prefix=mycluster- --function=CollectStats --path=event.json

### Invoke Local 

Run the specified function in your local workspace.

    sls invoke local --name-prefix=mycluster- --function=CollectStats --path=event.json


### Deployment

This example is made to work with the Serverless Framework dashboard, which includes advanced features such as CI/CD, monitoring, metrics, etc.

In order to deploy with dashboard, you need to first login with:

```
serverless login
```

install dependencies with:

```
npm install
```

and

```
pip install -r requirements.txt
```

and then perform deployment with:

```
serverless deploy
```

After running deploy, you should see output similar to:

```bash
erverless: Using Python specified in "runtime": python3.8
Serverless: Packaging Python WSGI handler...
Serverless: Generated requirements from /home/xxx/xxx/xxx/examples/aws-python-flask-api/requirements.txt in /home/xxx/xxx/xxx/examples/aws-python-flask-api/.serverless/requirements.txt...
Serverless: Using static cache of requirements found at /home/xxx/.cache/serverless-python-requirements/62f10436f9a1bb8040df30ef2db5736c8015b18256bf0b6f1b0cbb2640030244_slspyc ...
Serverless: Packaging service...
Serverless: Excluding development dependencies...
Serverless: Injecting required Python packages to package...
Serverless: Creating Stack...
Serverless: Checking Stack create progress...
........
Serverless: Stack create finished...
Serverless: Uploading CloudFormation file to S3...
Serverless: Uploading artifacts...
Serverless: Uploading service aws-python-flask-api.zip file to S3 (1.3 MB)...
Serverless: Validating template...
Serverless: Updating Stack...
Serverless: Checking Stack update progress...
.................................
Serverless: Stack update finished...
Service Information
service: aws-python-flask-api
stage: dev
region: us-east-1
stack: aws-python-flask-api-dev
resources: 12
api keys:
  None
endpoints:
  ANY - https://xxxxxxx.execute-api.us-east-1.amazonaws.com/dev/
  ANY - https://xxxxxxx.execute-api.us-east-1.amazonaws.com/dev/{proxy+}
functions:
  api: aws-python-flask-api-dev-api
layers:
  None
```

_Note_: In current form, after deployment, your API is public and can be invoked by anyone. For production deployments, you might want to configure an authorizer. For details on how to do that, refer to [http event docs](https://www.serverless.com/framework/docs/providers/aws/events/apigateway/).

### Invocation

After successful deployment, you can call the created application via HTTP:

```bash
curl https://xxxxxxx.execute-api.us-east-1.amazonaws.com/dev/
```

Which should result in the following response:

```
{"message":"Hello from root!"}
```

Calling the `/hello` path with:

```bash
curl https://xxxxxxx.execute-api.us-east-1.amazonaws.com/dev/hello
```

Should result in the following response:

```bash
{"message":"Hello from path!"}
```

If you try to invoke a path or method that does not have a configured handler, e.g. with:

```bash
curl https://xxxxxxx.execute-api.us-east-1.amazonaws.com/dev/nonexistent
```

You should receive the following response:

```bash
{"error":"Not Found!"}
```

### Local development

Thanks to capabilities of `serverless-wsgi`, it is also possible to run your application locally, however, in order to do that, you will need to first install `werkzeug` dependency, as well as all other dependencies listed in `requirements.txt`. It is recommended to use a dedicated virtual environment for that purpose. You can install all needed dependencies with the following commands:

```bash
pip install werkzeug
pip install -r requirements.txt
```

At this point, you can run your application locally with the following command:

```bash
serverless wsgi serve
```

For additional local development capabilities of `serverless-wsgi` plugin, please refer to corresponding [GitHub repository](https://github.com/logandk/serverless-wsgi).


### Commands

$ npm install -g npm@latest
$ npm install -g serverless

$ aws configure

$ serverless


You are not logged in or you do not have a Serverless account.

 Do you want to login/register to Serverless Dashboard? No

 Do you want to deploy your project? Yes


$ pip install pipenv

create virtualenv
$ pipenv shell

$ pip -V
$ pipenv shell
$ pipenv install
 
pip3 install PyQt5==5.9.2

// UserWarning: Matplotlib is currently using agg, which is a non-GUI backend, so cannot show the figure. plt.show()
pip install PyQt5

// C:\Users\<your username>\AppData\Local\Programs\Python\Python39\Scripts\pipenv.exe
// C:\Users\jetbrains\AppData\Roaming\Python\Python37\Scripts\pipenv.exe

pipenv install boto3
pipenv install elasticsearch
pipenv install requests
pipenv install requests-aws4auth
pipenv install elasticsearch
pipenv install seaborn

pipenv install flask

pipenv install "boto=1.4.4"

pipenv run python3 application

pipenv run python -c "print('hello')"

pipenv shell

// pip freeze results in pinned dependencies you can add to a requirements.txt

// https://pipenv-fork.readthedocs.io/en/latest/diagnose.html

C:\Python39\Scripts\pipenv.exe

$ npm install serverless-cloud-conformity



npx sls wsgi serve
