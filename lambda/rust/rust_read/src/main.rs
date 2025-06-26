use lambda_http::{run, service_fn, tracing, Error};
mod http_handler;
use http_handler::function_handler;
use aws_config::{BehaviorVersion, Region, SdkConfig};
use aws_sdk_dsql::auth_token::{AuthToken, AuthTokenGenerator, Config};
use bb8::Pool;
use bb8_postgres::PostgresConnectionManager;
use tokio_postgres::{NoTls, Config as PgConfig};
use std::{env, sync::Arc, time::Duration};

const TOKEN_EXPIRATION_SECONDS: u64 = 900; // 15 minutes
const TOKEN_REFRESH_SECONDS: u64 = 600;    // 10 minutes (refresh 5 min before expiry)
const POOL_MIN_CONNECTIONS: u32 = 1;
const POOL_MAX_CONNECTIONS: u32 = 5;
const CONNECTION_TIMEOUT_SECONDS: u64 = 10;

// Connection pool type alias for cleaner code
pub type ConnectionPool = Pool<PostgresConnectionManager<NoTls>>;

// Shared state for connection management
#[derive(Clone)]
pub struct AppState {
    pub pool: ConnectionPool,
    pub token_generator: Arc<AuthTokenGenerator>,
    pub sdk_config: Arc<SdkConfig>,
    pub cluster_endpoint: String,
    pub region: String,
}

impl AppState {
    /// Generate a fresh authentication token
    pub async fn generate_password_token(&self) -> Result<AuthToken, Box<dyn std::error::Error + Send + Sync>> {
        let token = self.token_generator
            .db_connect_admin_auth_token(&self.sdk_config)
            .await?;
        Ok(token)
    }

    /// Create a new connection pool with fresh authentication token
    pub async fn create_connection_pool(&self) -> Result<ConnectionPool, Box<dyn std::error::Error + Send + Sync>> {
        let password_token = self.generate_password_token().await?;
        
        let mut pg_config = PgConfig::new();
        pg_config
            .host(&self.cluster_endpoint)
            .port(5432)
            .dbname("postgres")
            .user("admin")
            .password(password_token.as_str())
            .ssl_mode(tokio_postgres::config::SslMode::Require)
            .options("sslnegotiation=direct");

        let manager = PostgresConnectionManager::new(pg_config, NoTls);
        
        let pool = Pool::builder()
            .min_idle(Some(POOL_MIN_CONNECTIONS))
            .max_size(POOL_MAX_CONNECTIONS)
            .connection_timeout(Duration::from_secs(CONNECTION_TIMEOUT_SECONDS))
            .idle_timeout(Some(Duration::from_secs(300))) // 5 minutes idle timeout
            .max_lifetime(Some(Duration::from_secs(TOKEN_REFRESH_SECONDS))) // Refresh before token expires
            .build(manager)
            .await?;

        println!("Created BB8 connection pool with {}-{} connections", POOL_MIN_CONNECTIONS, POOL_MAX_CONNECTIONS);
        Ok(pool)
    }

    /// Get pool statistics for monitoring
    pub fn get_pool_stats(&self) -> serde_json::Value {
        let state = self.pool.state();
        serde_json::json!({
            "pool_type": "BB8",
            "connections": {
                "total": state.connections,
                "idle": state.idle_connections,
                "max_size": POOL_MAX_CONNECTIONS,
                "min_idle": POOL_MIN_CONNECTIONS
            },
            "configuration": {
                "connection_timeout_seconds": CONNECTION_TIMEOUT_SECONDS,
                "idle_timeout_seconds": 300,
                "max_lifetime_seconds": TOKEN_REFRESH_SECONDS,
                "token_expiration_seconds": TOKEN_EXPIRATION_SECONDS
            }
        })
    }
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing::init_default_subscriber();

    // AWS Configuration from environment variables
    let region = env::var("DSQL_REGION")
        .or_else(|_| env::var("AWS_REGION"))
        .unwrap_or_else(|_| "us-east-1".to_string());
    let cluster_endpoint = env::var("CLUSTER_ENDPOINT")
        .expect("CLUSTER_ENDPOINT environment variable is required");
    
    println!("Initializing Rust Lambda with BB8 connection pooling");
    println!("Region: {}, Cluster: {}", region, cluster_endpoint);

    // Load AWS SDK configuration
    let sdk_config = aws_config::load_defaults(BehaviorVersion::latest()).await;

    // Create authentication token generator
    let region_clone = region.clone();
    let token_generator = AuthTokenGenerator::new(
        Config::builder()
            .hostname(&cluster_endpoint)
            .region(Region::new(region_clone))
            .expires_in(TOKEN_EXPIRATION_SECONDS)
            .build()
            .unwrap(),
    );

    // Create application state
    let app_state = AppState {
        pool: Pool::builder().build_unchecked(PostgresConnectionManager::new(PgConfig::new(), NoTls)), // Temporary placeholder
        token_generator: Arc::new(token_generator),
        sdk_config: Arc::new(sdk_config),
        cluster_endpoint: cluster_endpoint.clone(),
        region: region.clone(),
    };

    // Create the actual connection pool with authentication
    let connection_pool = app_state.create_connection_pool().await.map_err(|e| {
        println!("Failed to create BB8 connection pool: {:?}", e);
        lambda_http::Error::from(format!("Database connection error: {}", e))
    })?;

    // Update app state with the real pool
    let final_app_state = AppState {
        pool: connection_pool,
        token_generator: app_state.token_generator,
        sdk_config: app_state.sdk_config,
        cluster_endpoint,
        region,
    };

    println!("BB8 connection pool initialized successfully");
    println!("Pool stats: {}", final_app_state.get_pool_stats());

    // Start the Lambda runtime
    run(service_fn(move |event| {
        let state = final_app_state.clone();
        async move { function_handler(state, event).await }
    })).await
}
