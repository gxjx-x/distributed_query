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

### Environment Variables

Set the following environment variables or update them in the CDK stack:

```bash
export CLUSTER_ENDPOINT="your-dsql-cluster-endpoint"
export AWS_REGION="us-east-1"
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
