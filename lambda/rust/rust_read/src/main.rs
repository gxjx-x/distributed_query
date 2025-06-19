use lambda_http::{run, service_fn, tracing, Error};
mod http_handler;
use http_handler::function_handler;
use aws_config::{BehaviorVersion, Region};
use aws_sdk_dsql::auth_token::{AuthTokenGenerator,Config};
use sqlx::postgres::{PgConnectOptions, PgPoolOptions};
use std::{env, time::Duration};

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing::init_default_subscriber();

    // AWS 
    let region = "us-west-2";
    let cluster_endpoint = env::var("CLUSTER_ENDPOINT").expect("CLUSTER_ENDPOINT required");
    // Generate auth token
    let sdk_config = aws_config::load_defaults(BehaviorVersion::latest()).await;

    // CLUSTER PASSWORD
    let signer = AuthTokenGenerator::new(
        Config::builder()
            .hostname(&cluster_endpoint)
            .region(Region::new(region))
            .expires_in(900)
            .build()
            .unwrap(),
    );
    let password_token = signer
        .db_connect_admin_auth_token(&sdk_config)
        .await
        .unwrap(); // If it cannot get it, fail

    // Setup connections
    let connection_options = PgConnectOptions::new()
        .host(cluster_endpoint.as_str())
        .port(5432)
        .database("postgres")
        .username("admin")
        .password(password_token.as_str())
        .ssl_mode(sqlx::postgres::PgSslMode::VerifyFull);

    let pool = PgPoolOptions::new()
        .max_connections(1)
        .acquire_timeout(Duration::from_secs(10))
        .connect_with(connection_options.clone())
        .await
        .map_err(|e| {
            println!("Database connection error: {:?}", e);
            e
        })?;

    let shared = &pool;

    //run(service_fn(function_handler)).await
    run(service_fn(|event| function_handler(shared, event))).await
}
