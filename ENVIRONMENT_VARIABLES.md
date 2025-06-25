# Environment Variables Configuration

This document describes the environment variables used in the Distributed Query System.

## CDK Deployment Environment Variables

These environment variables can be set when deploying the CDK stack to override default values:

### Required for Custom Configuration
- `CLUSTER_ENDPOINT`: Aurora DSQL cluster endpoint
  - Default: `kmabttplhoiqau3uqavxpjofa4.dsql.us-east-1.on.aws`
  - Example: `export CLUSTER_ENDPOINT=your-cluster-endpoint.dsql.us-east-1.on.aws`

- `AWS_REGION`: AWS region for deployment (CDK deployment only)
  - Default: Uses CDK stack region or `us-east-1`
  - Example: `export AWS_REGION=us-west-2`
  - Note: This is used only during CDK deployment, not in Lambda runtime

## Lambda Function Environment Variables

These are automatically set by the CDK stack and passed to both Lambda functions:

### Python Lambda (`pythonRead`)
- `CLUSTER_ENDPOINT`: Aurora DSQL cluster endpoint
- `DSQL_REGION`: AWS region for DSQL client (falls back to AWS_REGION if not set)
- `CLUSTER_USER`: Database user (default: `admin`)

### Rust Lambda (`rustRead`)
- `CLUSTER_ENDPOINT`: Aurora DSQL cluster endpoint  
- `DSQL_REGION`: AWS region for DSQL client (falls back to AWS_REGION if not set)
- `CLUSTER_USER`: Database user (default: `admin`)

### Optional Lambda Configuration
- `TOKEN_EXPIRATION_SECONDS`: Token expiration time (default: 900 seconds)
- `TOKEN_REFRESH_SECONDS`: Token refresh time (default: 600 seconds)
- `POOL_MIN_CONNECTIONS`: Minimum connection pool size (default: 1)
- `POOL_MAX_CONNECTIONS`: Maximum connection pool size (default: 5)

## Deployment Examples

### Deploy with default configuration:
```bash
cdk deploy
```

### Deploy with custom cluster endpoint:
```bash
export CLUSTER_ENDPOINT=your-custom-endpoint.dsql.us-east-1.on.aws
cdk deploy
```

### Deploy to different region:
```bash
export AWS_REGION=us-west-2
export CLUSTER_ENDPOINT=your-endpoint.dsql.us-west-2.on.aws
cdk deploy
```

### Deploy with both custom values:
```bash
export CLUSTER_ENDPOINT=your-endpoint.dsql.eu-west-1.on.aws
export AWS_REGION=eu-west-1
cdk deploy
```

## Benefits of Environment Variable Configuration

1. **Flexibility**: Easy to deploy to different environments (dev, staging, prod)
2. **Security**: Sensitive values can be managed through secure environment variable systems
3. **Portability**: Same code can work across different AWS accounts and regions
4. **CI/CD Friendly**: Environment-specific configuration without code changes
5. **Multi-Region Support**: Easy deployment to different AWS regions

## Migration from Hardcoded Values

The system has been updated from hardcoded values to environment variables:

**Before:**
- Region: Hardcoded as `"us-east-1"`
- Cluster: Hardcoded as `"kmabttplhoiqau3uqavxpjofa4.dsql.us-east-1.on.aws"`

**After:**
- Region: `process.env.AWS_REGION || this.region || 'us-east-1'` (CDK), `DSQL_REGION` (Lambda)
- Cluster: `process.env.CLUSTER_ENDPOINT || 'kmabttplhoiqau3uqavxpjofa4.dsql.us-east-1.on.aws'`

This maintains backward compatibility while enabling flexible configuration.

## Important Notes

- `AWS_REGION` is reserved by Lambda runtime, so we use `DSQL_REGION` for Lambda functions
- Both Lambda functions fall back to the Lambda-provided `AWS_REGION` if `DSQL_REGION` is not set
- The CDK stack uses `AWS_REGION` for deployment configuration only
