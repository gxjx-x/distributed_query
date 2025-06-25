use lambda_http::{run, service_fn, tracing, Error};
mod http_handler;
use http_handler::function_handler;
use aws_config::{BehaviorVersion, Region, SdkConfig};
use aws_sdk_dsql::auth_token::{AuthToken, AuthTokenGenerator, Config};
use sqlx::postgres::{PgConnectOptions, PgPoolOptions};
use std::{env, sync::Arc, time::Duration};
use tokio::sync::RwLock;

const TOKEN_EXPIRATION_SECONDS: u64 = 900; // 15 minutes
const TOKEN_REFRESH_SECONDS: u64 = 600;    // 10 minutes (refresh 5 min before expiry)

// Shared state for connection management
#[derive(Clone)]
pub struct AppState {
    pub pool: sqlx::Pool<sqlx::Postgres>,
    pub connection_options: Arc<RwLock<PgConnectOptions>>,
}

async fn generate_password_token(
    signer: &AuthTokenGenerator,
    sdk_config: &SdkConfig,
) -> AuthToken {
    signer
        .db_connect_admin_auth_token(sdk_config)
        .await
        .unwrap()
}

async fn create_new_pool(connection_options: &PgConnectOptions) -> Result<sqlx::Pool<sqlx::Postgres>, sqlx::Error> {
    PgPoolOptions::new()
        .max_connections(5)
        .acquire_timeout(Duration::from_secs(10))
        .connect_with(connection_options.clone())
        .await
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing::init_default_subscriber();

    // AWS Configuration from environment variables
    let region = env::var("DSQL_REGION")
        .or_else(|_| env::var("AWS_REGION"))
        .unwrap_or_else(|_| "us-east-1".to_string());
    let cluster_endpoint = env::var("CLUSTER_ENDPOINT").expect("CLUSTER_ENDPOINT environment variable is required");
    
    // Generate auth token
    let sdk_config = aws_config::load_defaults(BehaviorVersion::latest()).await;

    // CLUSTER PASSWORD
    let signer = AuthTokenGenerator::new(
        Config::builder()
            .hostname(&cluster_endpoint)
            .region(Region::new(&region))
            .expires_in(TOKEN_EXPIRATION_SECONDS)
            .build()
            .unwrap(),
    );
    
    let password_token = generate_password_token(&signer, &sdk_config).await;

    // Setup connections
    let connection_options = PgConnectOptions::new()
        .host(cluster_endpoint.as_str())
        .port(5432)
        .database("postgres")
        .username("admin")
        .password(password_token.as_str())
        .ssl_mode(sqlx::postgres::PgSslMode::VerifyFull).options([("sslnegotiation", "direct")]);

    let pool = create_new_pool(&connection_options).await.map_err(|e| {
        println!("Database connection error: {:?}", e);
        e
    })?;

    let app_state = AppState {
        pool,
        connection_options: Arc::new(RwLock::new(connection_options)),
    };

    // Note: Token refresh is simplified for Lambda - each invocation gets a fresh token
    // For long-running services, you'd want to implement proper token refresh
    
    run(service_fn(move |event| {
        let state = app_state.clone();
        async move { function_handler(&state.pool, event).await }
    })).await
}
