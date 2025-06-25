import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as apigateway from 'aws-cdk-lib/aws-apigateway';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as s3deploy from 'aws-cdk-lib/aws-s3-deployment';
import * as cloudfront from 'aws-cdk-lib/aws-cloudfront';
import * as origins from 'aws-cdk-lib/aws-cloudfront-origins';
import * as path from 'path';
import { Effect, PolicyStatement } from 'aws-cdk-lib/aws-iam';
import {PythonFunction } from '@aws-cdk/aws-lambda-python-alpha';

export class DistributedQueryStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Get configuration from environment variables or use defaults
    const clusterEndpoint = process.env.CLUSTER_ENDPOINT || 'kmabttplhoiqau3uqavxpjofa4.dsql.us-east-1.on.aws';
    const awsRegion = process.env.AWS_REGION || this.region || 'us-east-1';

    // Python Read function
    const pythonRead = new PythonFunction(this, 'pythonRead', {
      runtime: lambda.Runtime.PYTHON_3_9,
      handler: 'lambda_handler',
      entry: (path.join(__dirname, '../lambda/python/python_read')),
      timeout: cdk.Duration.seconds(30),
      index: 'lambda_function.py',
      memorySize: 256,
      environment: {
        CLUSTER_ENDPOINT: clusterEndpoint,
        DSQL_REGION: awsRegion,
        CLUSTER_USER: 'admin'
      }
    });

    // Add DSQL permissions to Python function
    pythonRead.addToRolePolicy(new PolicyStatement({
      effect: Effect.ALLOW,
      actions: ["dsql:*"],
      resources: ["*"]
    }));

    // Rust Read function
    const rustRead = new lambda.Function(this, 'rustRead', {
      runtime: lambda.Runtime.PROVIDED_AL2023,
      handler: 'bootstrap',
      code: lambda.Code.fromAsset(path.join(__dirname, '../lambda/rust/rust_read'), {
        bundling: {
          image: lambda.Runtime.PROVIDED_AL2023.bundlingImage,
          command: ['cp', '/asset-input/bootstrap', '/asset-output/bootstrap'],
        },
      }),
      timeout: cdk.Duration.seconds(30),
      memorySize: 128,
      environment: {
        CLUSTER_ENDPOINT: clusterEndpoint,
        DSQL_REGION: awsRegion,
        CLUSTER_USER: 'admin'
      }
    });

    // Add DSQL permissions to Rust function
    rustRead.addToRolePolicy(new PolicyStatement({
      effect: Effect.ALLOW,
      actions: ["dsql:*"],
      resources: ["*"]
    }));

    // Create API Gateway with CORS enabled
    const api = new apigateway.RestApi(this, 'DistributedQueryApi', {
      restApiName: 'Distributed Query Service',
      description: 'This service provides SQL database read functionality',
      deployOptions: {
        stageName: 'prod',
      },
      // Enable CORS for all origins (for testing purposes only)
      defaultCorsPreflightOptions: {
        allowOrigins: apigateway.Cors.ALL_ORIGINS,
        allowMethods: apigateway.Cors.ALL_METHODS,
        allowHeaders: ['Content-Type', 'X-Amz-Date', 'Authorization', 'X-Api-Key', 'X-Amz-Security-Token', 'X-Requested-With'],
        allowCredentials: true,
        maxAge: cdk.Duration.days(1)
      }
    });

    // Create /read resource
    const readResource = api.root.addResource('read');
    
    // Create /read/python resource
    const pythonResource = readResource.addResource('python');
    
    // Create /read/rust resource
    const rustResource = readResource.addResource('rust');
    
    // Integrate the Python Lambda function with the API Gateway
    const pythonIntegration = new apigateway.LambdaIntegration(pythonRead, {
      requestTemplates: { 'application/json': '{ "statusCode": 200 }' }
    });

    // Integrate the Rust Lambda function with the API Gateway
    const rustIntegration = new apigateway.LambdaIntegration(rustRead, {
      requestTemplates: { 'application/json': '{ "statusCode": 200 }' }
    });

    // Add methods to the /read/python resource
    pythonResource.addMethod('GET', pythonIntegration);  // For reading data
    pythonResource.addMethod('POST', pythonIntegration); // For more complex read queries
    
    // Add methods to the /read/rust resource
    rustResource.addMethod('GET', rustIntegration);  // For reading data
    rustResource.addMethod('POST', rustIntegration); // For more complex read queries

    // Create S3 bucket for website hosting (private bucket with CloudFront)
    const websiteBucket = new s3.Bucket(this, 'WebsiteBucket', {
      bucketName: `distributed-query-website-${this.account}-${this.region}`,
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      // Remove public access settings - use CloudFront instead
    });

    // Deploy website content to S3
    new s3deploy.BucketDeployment(this, 'DeployWebsite', {
      sources: [s3deploy.Source.asset(path.join(__dirname, '../website'))],
      destinationBucket: websiteBucket,
    });

    // Create CloudFront distribution for the website
    const distribution = new cloudfront.Distribution(this, 'WebsiteDistribution', {
      defaultBehavior: {
        origin: origins.S3BucketOrigin.withOriginAccessControl(websiteBucket),
        viewerProtocolPolicy: cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
      },
      defaultRootObject: 'index.html',
    });
    
    // Output the API Gateway URL
    new cdk.CfnOutput(this, 'ApiUrl', {
      value: api.url,
      description: 'URL of the API Gateway',
    });

    // Output the Python endpoint URL
    new cdk.CfnOutput(this, 'PythonEndpoint', {
      value: `${api.url}read/python`,
      description: 'Python Lambda endpoint URL',
    });

    // Output the Rust endpoint URL
    new cdk.CfnOutput(this, 'RustEndpoint', {
      value: `${api.url}read/rust`,
      description: 'Rust Lambda endpoint URL',
    });

    // Output the website URLs
    new cdk.CfnOutput(this, 'WebsiteUrl', {
      value: `https://${distribution.distributionDomainName}`,
      description: 'CloudFront website URL',
    });

    // Output configuration information
    new cdk.CfnOutput(this, 'ClusterEndpoint', {
      value: clusterEndpoint,
      description: 'Aurora DSQL cluster endpoint being used',
    });

    new cdk.CfnOutput(this, 'Region', {
      value: awsRegion,
      description: 'AWS region being used',
    });
  }
}
