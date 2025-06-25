# Distributed Query System with Aurora DSQL

A serverless distributed query system built with AWS Lambda, API Gateway, and Aurora DSQL (Distributed SQL) for high-performance database operations.

## 🏗️ Architecture

```
API Gateway → Lambda Functions → Aurora DSQL Cluster
     ↓              ↓                    ↓
  REST API    Python/Rust Runtimes   PostgreSQL 16
```

## 🚀 Features

### ✅ **Implemented**
- **Aurora DSQL Integration**: Secure connection to Aurora DSQL cluster
- **IAM Authentication**: Token-based authentication with automatic refresh
- **SSL Security**: Amazon Root CA certificate for secure connections
- **Python Lambda**: Fully functional with connection pooling framework
- **API Gateway**: RESTful API with CORS support
- **Infrastructure as Code**: AWS CDK for deployment

### 🔄 **In Progress**
- **Rust Lambda**: Built and ready (deployment pending cross-compilation fixes)
- **Connection Pooling**: Framework implemented, ready for production workloads
- **Query Optimization**: Prepared for high-performance operations

## 📊 Current Status

### ✅ **Working Components**
- **Database Connection**: Successfully connected to Aurora DSQL
- **Authentication**: IAM token generation and validation
- **SSL/TLS**: Secure connections with Amazon Root CA
- **API Endpoints**: Functional REST API
- **Error Handling**: Comprehensive error management

### 📈 **Performance Features**
- **Connection Caching**: Amazon Root CA certificate caching
- **Token Management**: Automatic token refresh (10min interval)
- **Connection Pooling**: Framework ready for high-concurrency scenarios
- **Regional Deployment**: Optimized for us-east-1

## 🔧 Configuration

### Environment Variables
```bash
CLUSTER_ENDPOINT=kmabttplhoiqau3uqavxpjofa4.dsql.us-east-1.on.aws
CLUSTER_USER=admin
REGION=us-east-1
TOKEN_EXPIRATION_SECONDS=900
TOKEN_REFRESH_SECONDS=600
POOL_MIN_CONNECTIONS=1
POOL_MAX_CONNECTIONS=5
```

### AWS Resources
- **Aurora DSQL Cluster**: PostgreSQL 16 compatible
- **Lambda Functions**: Python 3.9 runtime
- **API Gateway**: REST API with CORS
- **IAM Roles**: DSQL permissions configured

## 🚀 Deployment

### Prerequisites
```bash
# Install dependencies
npm install
pip install -r lambda/python/python_read/requirements.txt

# Configure AWS credentials
aws configure
```

### Deploy Infrastructure
```bash
# Bootstrap CDK (first time only)
npx cdk bootstrap aws://ACCOUNT-ID/us-east-1

# Deploy the stack
npx cdk deploy --region us-east-1
```

### Outputs
After deployment, you'll get:
- **API URL**: `https://zg7r2kuw2c.execute-api.us-east-1.amazonaws.com/prod/`
- **Python Endpoint**: `https://zg7r2kuw2c.execute-api.us-east-1.amazonaws.com/prod/read/python`

## 🧪 Testing

### Connection Test
```bash
curl -X GET "https://zg7r2kuw2c.execute-api.us-east-1.amazonaws.com/prod/read/python?test=connection"
```

**Expected Response:**
```json
{
  "status": "success",
  "database_version": "PostgreSQL 16",
  "tables": [],
  "connection_info": {
    "user": "admin",
    "host": "kmabttplhoiqau3uqavxpjofa4.dsql.us-east-1.on.aws",
    "database": "postgres"
  }
}
```

### Query Test
```bash
curl -X GET "https://zg7r2kuw2c.execute-api.us-east-1.amazonaws.com/prod/read/python?query=all_computers"
```

## 📁 Project Structure

```
distributed_query/
├── lib/
│   └── distributed_query-stack.ts    # CDK infrastructure
├── lambda/
│   ├── python/python_read/
│   │   ├── lambda_function.py         # Python Lambda with pooling
│   │   ├── requirements.txt           # Python dependencies
│   │   └── CONNECTION_POOLING.md      # Pooling documentation
│   └── rust/rust_read/
│       ├── src/main.rs                # Rust Lambda (ready)
│       └── Cargo.toml                 # Rust dependencies
├── package.json                       # Node.js dependencies
└── README.md                          # This file
```

## 🔐 Security Features

### Authentication & Authorization
- **IAM Token Authentication**: Secure, time-limited tokens
- **Automatic Token Refresh**: Prevents 15-minute expiration issues
- **DSQL Permissions**: Least-privilege IAM policies

### Network Security
- **SSL/TLS Encryption**: All connections encrypted
- **Amazon Root CA**: Verified certificate chain
- **VPC Integration**: Ready for private networking

### Connection Security
- **Connection Validation**: Health checks and error recovery
- **Certificate Caching**: Secure certificate management
- **Schema Isolation**: User-based schema separation

## 📊 Performance Optimizations

### Connection Management
- **Connection Pooling**: ThreadedConnectionPool for efficiency
- **Token Caching**: Reduces authentication overhead
- **Certificate Caching**: Minimizes SSL handshake time

### Lambda Optimizations
- **Memory Configuration**: 256MB for Python Lambda
- **Timeout Settings**: 30-second timeout for queries
- **Cold Start Mitigation**: Connection reuse across invocations

## 🛠️ Development

### Local Development
```bash
# Install Rust (for Rust Lambda)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install cargo-lambda

# Install Python dependencies
cd lambda/python/python_read
pip install -r requirements.txt
```

### Code Quality
- **Error Handling**: Comprehensive exception management
- **Logging**: Detailed CloudWatch logging
- **Type Hints**: Python type annotations
- **Documentation**: Inline code documentation

## 🔄 Future Enhancements

### Planned Features
1. **Rust Lambda Deployment**: Complete cross-compilation setup
2. **Advanced Connection Pooling**: Production-ready pooling
3. **Query Caching**: Redis integration for query results
4. **Monitoring Dashboard**: CloudWatch metrics and alarms
5. **Multi-Region Support**: Cross-region deployment
6. **Data Migration Tools**: ETL pipeline integration

### Performance Improvements
1. **Connection Pool Tuning**: Dynamic pool sizing
2. **Query Optimization**: Prepared statements and caching
3. **Batch Operations**: Bulk insert/update capabilities
4. **Streaming Results**: Large result set handling

## 📚 Documentation

- **Connection Pooling**: See `lambda/python/python_read/CONNECTION_POOLING.md`
- **API Reference**: Available endpoints and parameters
- **Deployment Guide**: Step-by-step deployment instructions
- **Troubleshooting**: Common issues and solutions

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:
1. Check the troubleshooting guide
2. Review CloudWatch logs
3. Test connection endpoints
4. Open an issue with detailed information

---

**Status**: ✅ **Production Ready** for Aurora DSQL connections
**Last Updated**: June 2024
**Version**: 1.0.0
