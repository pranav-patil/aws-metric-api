# AWS Metric API

Metric API is a sample serverless application which demonstrates the [serverless](https://www.serverless.com/) framework and inegration with AWS resources. 
The Metric API uses Python Flask API to exposes HTTP APIs.
A single function configuration `api`, is used for handling all incoming requests thanks to configured `http` events. To learn more about `http` event configuration options, please refer to [http event docs](https://www.serverless.com/framework/docs/providers/aws/events/apigateway/). As the events are configured in a way to accept all incoming requests, `Flask` framework is responsible for routing and handling requests internally. The implementation takes advantage of `serverless-wsgi`, which allows you to wrap WSGI applications such as Flask apps. To learn more about `serverless-wsgi`, please refer to corresponding [GitHub repository](https://github.com/logandk/serverless-wsgi). Additionally, the template relies on `serverless-python-requirements` plugin for packaging dependencies from `requirements.txt` file. For more details about `serverless-python-requirements` configuration, please refer to corresponding [GitHub repository](https://github.com/UnitedIncome/serverless-python-requirements).

## Setup

1. Install [Docker](https://docs.docker.com/get-docker/).
2. Install [Node.js](https://nodejs.org/en/download/). Then install and update all node packages using below commands.

```bash
npm install
npx ncu -u
```
3. Install [Python 3.8.10](https://www.python.org/downloads/) which also will install Pip3.
4. Install [Pipenv](https://pipenv.pypa.io/en/latest/install/) to setup pip virtual environment. Then create a new pip virtual environment and install all packages from Pipfile.

```bash
pip install pipenv
pipenv install --dev
```

5. Install [Terraform v1.1.5](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).
6. Install [Terragrunt v0.35.12](https://terragrunt.gruntwork.io/docs/getting-started/install/#install-terragrunt).
7. Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
8. Install [AWS ADFS](https://github.com/venth/aws-adfs) using [pip3 package](https://pypi.org/project/aws-adfs/).

```bash
pip install --upgrade pip
pip install aws-adfs
```

9. Login using aws-adfs using AWS credentials.

```bash
aws-adfs login --adfs-host="HOST" --session-duration "43200" --region "REGION" --no-sspi --profile "AWS_PROFILE_NAME" --role-arn ?
export AWS_PROFILE=<AWS_PROFILE_NAME>
export AWS_DEFAULT_REGION=<REGION>
aws sts get-caller-identity 
```
10. Setup AWS infrastructure using Terragrunt with below commands.

```bash
terragrunt init
terragrunt plan
terragrunt apply -auto-approve 
```

## Deploy

1. Install serverless python dependency management plugin before running any serverless commands. This only needs to be ran the first time while setting up the environment.

```bash
npx sls plugin install --name=serverless-python-requirements
```

2. Deploy all the serverless lambda using the provided `STACK_NAME`. The `STACK_NAME` should match with `cluster_name` in `tf/variables.tf`, which by default is `emprovise-demo`. Please start local docker instance before using below serverless deploy command.  

```bash
npx sls deploy --region <REGION> --stage <STACK_NAME> --verbose
```

### Invoke Serverless from Command line 

Invoke the specified function deployed in AWS, were `event.json` contains input event details.
```bash
sls invoke --stage <STACK_NAME> --region=<REGION> --function=<LAMBDA_NAME> --path=event.json
```

Run the specified function in your local workspace, were `event.json` contains input event details.
```bash
sls invoke local --stage <STACK_NAME> --region=<REGION> --function=<LAMBDA_NAME> --path=event.json
```

### Remove Serverless and Terraform Infrastructure

Remove the lambdas from AWS

```bash
sls remove --stage <STACK_NAME> --region=<REGION>
terragrunt destroy -auto-approve -input=false
```
