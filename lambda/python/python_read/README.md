# Python Lambda Function for Distributed Query

This Python Lambda function replicates the functionality of the Rust version, providing an API to query the computer database.

## Features

- Connects to Aurora PostgreSQL using IAM authentication
- Supports all the same query types as the Rust version:
  - `all_computers`: Get all computers in the database
  - `manuf_stats`: Get manufacturer statistics
  - `cpus`: Get all CPU architectures
  - `year_stats`: Find computers by year
  - `cpu_computers`: Find computers by CPU architecture
  - `search`: Search computers with weighted relevance

## Deployment

### Prerequisites

- AWS CLI configured with appropriate permissions
- Python 3.9 or later

### Steps

1. Install dependencies:
   ```
   pip install -r requirements.txt -t .
   ```

2. Create a deployment package:
   ```
   zip -r ../python_read.zip .
   ```

3. Deploy to AWS Lambda:
   ```
   aws lambda create-function \
     --function-name python_read \
     --runtime python3.9 \
     --handler lambda_function.lambda_handler \
     --zip-file fileb://../python_read.zip \
     --role <your-lambda-execution-role-arn> \
     --environment Variables={CLUSTER_ENDPOINT=<your-cluster-endpoint>} \
     --timeout 30 \
     --memory-size 256
   ```

4. Add API Gateway trigger to expose the Lambda function as an HTTP endpoint.

## Environment Variables

- `CLUSTER_ENDPOINT`: The Aurora PostgreSQL cluster endpoint (required)

## IAM Permissions

The Lambda function requires the following permissions:
- `dsql:GenerateDbAuthToken`
- `rds-db:connect`
- Basic Lambda execution permissions

## API Usage

The Lambda function accepts the following query parameters:

- `query`: The type of query to execute (default: `all_computers`)
- `year`: The year to filter by (for `year_stats` query)
- `cpu`: The CPU architecture to filter by (for `cpu_computers` query)
- `term`: The search term (for `search` query)

Example API calls:
- `/read/python?query=all_computers`
- `/read/python?query=manuf_stats`
- `/read/python?query=cpus`
- `/read/python?query=year_stats&year=1985`
- `/read/python?query=cpu_computers&cpu=MOS%206502`
- `/read/python?query=search&term=apple`
