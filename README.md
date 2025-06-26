# Distributed Query System

A serverless distributed query system with dual-backend architecture (Python and Rust) using AWS Lambda, API Gateway, and Aurora DSQL.

## Prerequisites

- **Node.js** (v18 or later)
- **AWS CLI** configured with appropriate permissions
- **AWS CDK** v2
- **Python** 3.9+
- **Rust** (for Rust Lambda development)

## Installation

### 1. Clone and Install Dependencies

```bash
git clone <repository-url>
cd distributed_query

# Install CDK dependencies
npm install

# Install Python Lambda dependencies
cd lambda/python/python_read
pip install -r requirements.txt
cd ../../..

# Install Rust (if developing Rust Lambda)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### 2. AWS Configuration

```bash
# Configure AWS credentials
aws configure

# Bootstrap CDK (first time only)
npx cdk bootstrap
```

## Configuration

### Required Environment Variables

The system requires several environment variables to be configured. These can be set in your shell environment or updated directly in the CDK stack configuration.

#### Core Database Configuration

```bash
# Aurora DSQL cluster endpoint (REQUIRED)
export CLUSTER_ENDPOINT="your-dsql-cluster-endpoint.dsql.region.on.aws"

# AWS region where resources are deployed (REQUIRED)
export AWS_REGION="us-east-1"

# Database user for DSQL connections (REQUIRED)
export CLUSTER_USER="admin"
```

#### Connection Pool Configuration (Python Lambda)

```bash
# Connection pool settings
export POOL_MIN_CONNECTIONS="1"        # Minimum connections to maintain
export POOL_MAX_CONNECTIONS="5"        # Maximum connections allowed
export CONNECTION_TIMEOUT="30"         # Connection timeout in seconds

# Token management
export TOKEN_EXPIRATION_SECONDS="900"  # Token lifetime (15 minutes)
export TOKEN_REFRESH_SECONDS="600"     # Token refresh interval (10 minutes)
```

#### BB8 Pool Configuration (Rust Lambda)

```bash
# BB8 async connection pool settings
export BB8_MIN_CONNECTIONS="1"         # Minimum idle connections
export BB8_MAX_CONNECTIONS="5"         # Maximum total connections
export BB8_CONNECTION_TIMEOUT="10"     # Connection acquisition timeout
export BB8_IDLE_TIMEOUT="300"          # Idle connection timeout (5 minutes)
export BB8_MAX_LIFETIME="600"          # Maximum connection lifetime (10 minutes)
```

#### Optional Configuration

```bash
# Lambda function settings
export LAMBDA_TIMEOUT="30"             # Lambda timeout in seconds
export PYTHON_MEMORY_SIZE="256"        # Python Lambda memory (MB)
export RUST_MEMORY_SIZE="128"          # Rust Lambda memory (MB)

# Logging and monitoring
export LOG_LEVEL="INFO"                # Logging level (DEBUG, INFO, WARN, ERROR)
export ENABLE_DETAILED_LOGGING="false" # Enable detailed connection logging
```

### CDK Configuration

Alternatively, you can set these values directly in the CDK stack file (`lib/distributed_query-stack.ts`):

```typescript
// Core configuration
const clusterEndpoint = process.env.CLUSTER_ENDPOINT || 'your-default-endpoint';
const awsRegion = process.env.AWS_REGION || 'us-east-1';

// Lambda environment variables
environment: {
  CLUSTER_ENDPOINT: clusterEndpoint,
  DSQL_REGION: awsRegion,
  CLUSTER_USER: 'admin',
  POOL_MIN_CONNECTIONS: '1',
  POOL_MAX_CONNECTIONS: '5',
  TOKEN_EXPIRATION_SECONDS: '900',
  TOKEN_REFRESH_SECONDS: '600'
}
```

### Environment Variable Descriptions

| Variable | Purpose | Default | Required |
|----------|---------|---------|----------|
| `CLUSTER_ENDPOINT` | Aurora DSQL cluster endpoint URL | None | ✅ Yes |
| `AWS_REGION` | AWS region for deployment | us-east-1 | ✅ Yes |
| `CLUSTER_USER` | Database username | admin | ✅ Yes |
| `POOL_MIN_CONNECTIONS` | Minimum connections in pool | 1 | ❌ No |
| `POOL_MAX_CONNECTIONS` | Maximum connections in pool | 5 | ❌ No |
| `TOKEN_EXPIRATION_SECONDS` | Token lifetime | 900 | ❌ No |
| `TOKEN_REFRESH_SECONDS` | Token refresh interval | 600 | ❌ No |
| `CONNECTION_TIMEOUT` | Connection timeout | 30 | ❌ No |
| `LOG_LEVEL` | Logging verbosity | INFO | ❌ No |

### Setting Environment Variables

#### For Local Development:
```bash
# Create a .env file (not committed to git)
cat > .env << EOF
CLUSTER_ENDPOINT=your-cluster-endpoint.dsql.us-east-1.on.aws
AWS_REGION=us-east-1
CLUSTER_USER=admin
POOL_MIN_CONNECTIONS=1
POOL_MAX_CONNECTIONS=5
TOKEN_EXPIRATION_SECONDS=900
TOKEN_REFRESH_SECONDS=600
EOF

# Source the environment file
source .env
```

#### For Production Deployment:
```bash
# Set environment variables before deployment
export CLUSTER_ENDPOINT="prod-cluster.dsql.us-east-1.on.aws"
export AWS_REGION="us-east-1"
export CLUSTER_USER="admin"

# Deploy with environment variables
npx cdk deploy --require-approval never
```

### Aurora DSQL Setup

1. Create an Aurora DSQL cluster in AWS Console
2. Note the cluster endpoint
3. Ensure your AWS credentials have DSQL permissions

## Deployment

### Deploy the Complete Stack

```bash
# Deploy infrastructure
npx cdk deploy --require-approval never

# Note the outputs:
# - API Gateway URL
# - Python Lambda endpoint
# - Rust Lambda endpoint
# - Website URL
```

### Build Rust Lambda (Optional)

```bash
cd lambda/rust/rust_read

# Build for Lambda
cargo build --release

# Create bootstrap file
cp target/release/rust_read bootstrap
```

## Project Structure

```
distributed_query/
├── lib/
│   └── distributed_query-stack.ts    # CDK infrastructure
├── lambda/
│   ├── python/python_read/           # Python Lambda with connection pooling
│   │   ├── lambda_function.py
│   │   ├── requirements.txt
│   │   └── database/                 # Database modules
│   └── rust/rust_read/               # Rust Lambda with BB8 pooling
│       ├── src/
│       └── Cargo.toml
├── website/                          # Frontend website
│   ├── index.html
│   └── debug.html
├── package.json
└── README.md
```

## Testing

### Test API Endpoints

```bash
# Test Python backend
curl "https://YOUR-API-GATEWAY-URL/prod/read/python?query=health"

# Test Rust backend  
curl "https://YOUR-API-GATEWAY-URL/prod/read/rust?query=health"

# Test data retrieval
curl "https://YOUR-API-GATEWAY-URL/prod/read/python?query=all_computers"
```

### Test Website

Open the CloudFront URL in your browser to access the web interface with backend switching capability.

## Configuration Options

### Lambda Memory and Timeout

Update in `lib/distributed_query-stack.ts`:

```typescript
// Python Lambda
memorySize: 256,
timeout: cdk.Duration.seconds(30),

// Rust Lambda  
memorySize: 128,
timeout: cdk.Duration.seconds(30),
```

### Connection Pool Settings

Python Lambda environment variables:
- `POOL_MIN_CONNECTIONS`: Minimum pool connections (default: 1)
- `POOL_MAX_CONNECTIONS`: Maximum pool connections (default: 5)
- `TOKEN_EXPIRATION_SECONDS`: Token lifetime (default: 900)
- `TOKEN_REFRESH_SECONDS`: Token refresh interval (default: 600)

## Cleanup

### Remove All Resources

```bash
# Destroy the CDK stack
npx cdk destroy

# This will remove:
# - Lambda functions
# - API Gateway
# - S3 bucket and CloudFront distribution
# - IAM roles and policies
# - Custom resources
```

**Note:** Aurora DSQL cluster must be deleted manually from AWS Console if no longer needed.

## Troubleshooting

### Common Issues

1. **CDK Bootstrap Required**
   ```bash
   npx cdk bootstrap aws://ACCOUNT-ID/REGION
   ```

2. **AWS Permissions**
   - Ensure IAM user has CDK deployment permissions
   - Verify DSQL access permissions

3. **Rust Cross-Compilation**
   - Use Docker for consistent Linux builds on macOS
   - Ensure `bootstrap` file has correct permissions

4. **Website Not Loading**
   - Check CloudFront distribution status
   - Verify S3 bucket deployment
   - Check API Gateway URLs in website files

### Logs and Monitoring

- **Lambda Logs**: CloudWatch `/aws/lambda/FUNCTION-NAME`
- **API Gateway Logs**: Enable in API Gateway console
- **CDK Deployment**: Check CloudFormation events

## Support

For issues:
1. Check CloudWatch logs
2. Verify AWS permissions
3. Test individual components
4. Review CDK deployment status
