import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { RustFunction } from 'cargo-lambda-cdk';
import * as apigateway from 'aws-cdk-lib/aws-apigateway';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as path from 'path';
import { Effect, PolicyStatement } from 'aws-cdk-lib/aws-iam';
import {PythonFunction } from '@aws-cdk/aws-lambda-python-alpha';

export class DistributedQueryStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Cluster endpoint for both Lambda functions
    const clusterEndpoint = 'ruabudpb2b53ifnbw22anc765i.dsql.us-west-2.on.aws';

    // Rust Read function
    const rustRead = new RustFunction(this, 'rustRead', {
      manifestPath: 'lambda/rust/rust_read/Cargo.toml',
      runtime: 'provided.al2023',
      timeout: cdk.Duration.seconds(30),
      memorySize: 128,
      environment: {
        CLUSTER_ENDPOINT: clusterEndpoint
      }
    });

    // Add DSQL permissions to Rust function
    rustRead.addToRolePolicy(new PolicyStatement({
      effect: Effect.ALLOW,
      actions: ["dsql:*"],
      resources: ["*"]
    }));

    const pythonRead = new PythonFunction(this, 'pythonRead', {
      runtime: lambda.Runtime.PYTHON_3_9,
      handler: 'lambda_handler',
      entry: (path.join(__dirname, '../lambda/python/python_read')),
      timeout: cdk.Duration.seconds(30),
      index: 'lambda_function.py',
      memorySize: 256,
      environment: {
        CLUSTER_ENDPOINT: clusterEndpoint
      }
    });

    // Add DSQL permissions to Python function
    pythonRead.addToRolePolicy(new PolicyStatement({
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
    
    // Create /read/rust resource
    const rustResource = readResource.addResource('rust');
    
    // Create /read/python resource
    const pythonResource = readResource.addResource('python');
    
    // Integrate the Rust Lambda function with the API Gateway
    const rustIntegration = new apigateway.LambdaIntegration(rustRead, {
      requestTemplates: { 'application/json': '{ "statusCode": 200 }' }
    });

    // Integrate the Python Lambda function with the API Gateway
    const pythonIntegration = new apigateway.LambdaIntegration(pythonRead, {
      requestTemplates: { 'application/json': '{ "statusCode": 200 }' }
    });

    // Add methods to the /read/rust resource
    rustResource.addMethod('GET', rustIntegration);  // For reading data
    rustResource.addMethod('POST', rustIntegration); // For more complex read queries
    
    // Add methods to the /read/python resource
    pythonResource.addMethod('GET', pythonIntegration);  // For reading data
    pythonResource.addMethod('POST', pythonIntegration); // For more complex read queries
    
    // Output the API Gateway URL
    new cdk.CfnOutput(this, 'ApiUrl', {
      value: api.url,
      description: 'URL of the API Gateway',
    });

    // Output the Rust endpoint URL
    new cdk.CfnOutput(this, 'RustEndpoint', {
      value: `${api.url}read/rust`,
      description: 'Rust Lambda endpoint URL',
    });

    // Output the Python endpoint URL
    new cdk.CfnOutput(this, 'PythonEndpoint', {
      value: `${api.url}read/python`,
      description: 'Python Lambda endpoint URL',
    });
  }
}
