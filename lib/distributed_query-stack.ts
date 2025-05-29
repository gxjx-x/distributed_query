import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { RustFunction } from 'cargo-lambda-cdk';
import * as apigateway from 'aws-cdk-lib/aws-apigateway';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import { Effect, PolicyStatement } from 'aws-cdk-lib/aws-iam';

export class DistributedQueryStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Rust Read function
    const rustRead = new RustFunction(this, 'rustRead', {
      manifestPath: 'lambda/rust/rust_read/Cargo.toml',
      runtime: 'provided.al2023',
      timeout: cdk.Duration.seconds(30),
      memorySize: 128,
      environment: {
        //CLUSTER_ENDPOINT: 'ruabudpb2b53ifnbw22anc765i.dsql.us-east-1.on.aws'
        CLUSTER_ENDPOINT: 'ruabudpb2b53ifnbw22anc765i.dsql.us-west-2.on.aws'
      }
    });

    // FIX: THIS HAS A LOT OF PERMISSIONS
    rustRead.addToRolePolicy(new PolicyStatement({
      effect: Effect.ALLOW,
      actions: ["dsql:*"],
      resources: ["*"]
    }))

    // Create API Gateway
    const api = new apigateway.RestApi(this, 'DistributedQueryApi', {
      restApiName: 'Distributed Query Service',
      description: 'This service provides SQL database read functionality',
      deployOptions: {
        stageName: 'prod',
      },
    });

    // Create /read resource
    const readResource = api.root.addResource('read');
    
    // Create /read/rust resource
    const rustResource = readResource.addResource('rust');
    
    // Integrate the Rust Lambda function with the API Gateway
    const rustIntegration = new apigateway.LambdaIntegration(rustRead, {
      requestTemplates: { 'application/json': '{ "statusCode": 200 }' }
    });

    // Add methods to the /read/rust resource
    rustResource.addMethod('GET', rustIntegration);  // For reading data
    rustResource.addMethod('POST', rustIntegration); // For more complex read queries
    
    // Output the API Gateway URL
    new cdk.CfnOutput(this, 'ApiUrl', {
      value: api.url,
      description: 'URL of the API Gateway',
    });
  }
}
