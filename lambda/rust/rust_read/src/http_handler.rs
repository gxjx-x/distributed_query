use lambda_http::{http::StatusCode, Error, Request, RequestExt, Response};
use serde::{Deserialize, Serialize};
use sqlx::{prelude::FromRow, Pool, Postgres};
use uuid::Uuid;
use std::collections::HashMap;

// Computer struct matching our simple database schema
#[derive(Debug, FromRow, Serialize, Deserialize)]
struct Computer {
    id: Uuid,
    model: String,
    manufacturer: String,
    year: i32,
    cpu: String,
    ram_kb: i32,
    storage: String,
}

// Response structures
#[derive(Serialize)]
struct ApiResponse<T> {
    status: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    message: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    count: Option<usize>,
    #[serde(skip_serializing_if = "Option::is_none")]
    data: Option<T>,
    #[serde(skip_serializing_if = "Option::is_none")]
    manufacturers: Option<Vec<String>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    years: Option<Vec<i32>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    cpus: Option<Vec<String>>,
}

fn create_cors_headers() -> Vec<(&'static str, &'static str)> {
    vec![
        ("Content-Type", "application/json"),
        ("Access-Control-Allow-Origin", "*"),
        ("Access-Control-Allow-Methods", "GET, POST, OPTIONS"),
        ("Access-Control-Allow-Headers", "Content-Type"),
    ]
}

async fn get_all_computers(pool: &Pool<Postgres>) -> Result<Response<String>, Error> {
    let computers: Vec<Computer> = sqlx::query_as(
        "SELECT id, model, manufacturer, year, cpu, ram_kb, storage FROM computers ORDER BY year, manufacturer"
    )
    .fetch_all(pool)
    .await
    .map_err(|e| {
        println!("Database query error: {:?}", e);
        e
    })?;

    let response = ApiResponse {
        status: "success".to_string(),
        message: Some("Computers data retrieved successfully".to_string()),
        count: Some(computers.len()),
        data: Some(computers),
        manufacturers: None,
        years: None,
        cpus: None,
    };

    let mut builder = Response::builder().status(StatusCode::OK);
    for (key, value) in create_cors_headers() {
        builder = builder.header(key, value);
    }

    Ok(builder.body(serde_json::to_string(&response)?)?)
}

async fn get_manufacturers(pool: &Pool<Postgres>) -> Result<Response<String>, Error> {
    let manufacturers: Vec<String> = sqlx::query_scalar(
        "SELECT DISTINCT manufacturer FROM computers ORDER BY manufacturer"
    )
    .fetch_all(pool)
    .await
    .map_err(|e| {
        println!("Database query error: {:?}", e);
        e
    })?;

    let response: ApiResponse<()> = ApiResponse {
        status: "success".to_string(),
        message: None,
        count: Some(manufacturers.len()),
        data: None,
        manufacturers: Some(manufacturers),
        years: None,
        cpus: None,
    };

    let mut builder = Response::builder().status(StatusCode::OK);
    for (key, value) in create_cors_headers() {
        builder = builder.header(key, value);
    }

    Ok(builder.body(serde_json::to_string(&response)?)?)
}

async fn get_years(pool: &Pool<Postgres>) -> Result<Response<String>, Error> {
    let years: Vec<i32> = sqlx::query_scalar(
        "SELECT DISTINCT year FROM computers ORDER BY year"
    )
    .fetch_all(pool)
    .await
    .map_err(|e| {
        println!("Database query error: {:?}", e);
        e
    })?;

    let response: ApiResponse<()> = ApiResponse {
        status: "success".to_string(),
        message: None,
        count: Some(years.len()),
        data: None,
        manufacturers: None,
        years: Some(years),
        cpus: None,
    };

    let mut builder = Response::builder().status(StatusCode::OK);
    for (key, value) in create_cors_headers() {
        builder = builder.header(key, value);
    }

    Ok(builder.body(serde_json::to_string(&response)?)?)
}

async fn get_cpus(pool: &Pool<Postgres>) -> Result<Response<String>, Error> {
    let cpus: Vec<String> = sqlx::query_scalar(
        "SELECT DISTINCT cpu FROM computers ORDER BY cpu"
    )
    .fetch_all(pool)
    .await
    .map_err(|e| {
        println!("Database query error: {:?}", e);
        e
    })?;

    let response: ApiResponse<()> = ApiResponse {
        status: "success".to_string(),
        message: None,
        count: Some(cpus.len()),
        data: None,
        manufacturers: None,
        years: None,
        cpus: Some(cpus),
    };

    let mut builder = Response::builder().status(StatusCode::OK);
    for (key, value) in create_cors_headers() {
        builder = builder.header(key, value);
    }

    Ok(builder.body(serde_json::to_string(&response)?)?)
}

async fn test_connection(pool: &Pool<Postgres>) -> Result<Response<String>, Error> {
    // Test basic connectivity
    let version: String = sqlx::query_scalar("SELECT version()")
        .fetch_one(pool)
        .await
        .map_err(|e| {
            println!("Database connection test error: {:?}", e);
            e
        })?;

    // Test if we can list tables
    let tables: Vec<String> = sqlx::query_scalar(
        "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name"
    )
    .fetch_all(pool)
    .await
    .unwrap_or_default();

    let mut connection_info = HashMap::new();
    connection_info.insert("user", "admin");
    connection_info.insert("database", "postgres");

    let response = serde_json::json!({
        "status": "success",
        "database_version": version,
        "tables": tables,
        "connection_info": connection_info
    });

    let mut builder = Response::builder().status(StatusCode::OK);
    for (key, value) in create_cors_headers() {
        builder = builder.header(key, value);
    }

    Ok(builder.body(response.to_string())?)
}

async fn health_check() -> Result<Response<String>, Error> {
    let response = serde_json::json!({
        "status": "healthy",
        "timestamp": chrono::Utc::now().to_rfc3339(),
        "service": "distributed-query-rust",
        "database": "connected"
    });

    let mut builder = Response::builder().status(StatusCode::OK);
    for (key, value) in create_cors_headers() {
        builder = builder.header(key, value);
    }

    Ok(builder.body(response.to_string())?)
}

async fn handle_unknown_query(query: &str) -> Result<Response<String>, Error> {
    let response = serde_json::json!({
        "message": format!("Query type '{}' is ready for implementation", query),
        "available_queries": ["test", "all_computers", "manufacturers", "years", "cpus", "health"],
        "status": "success",
        "query_received": query
    });

    let mut builder = Response::builder().status(StatusCode::OK);
    for (key, value) in create_cors_headers() {
        builder = builder.header(key, value);
    }

    Ok(builder.body(response.to_string())?)
}

pub async fn function_handler(
    pool: &Pool<Postgres>,
    event: Request,
) -> Result<Response<String>, Error> {
    // Handle CORS preflight requests
    if event.method() == "OPTIONS" {
        let mut builder = Response::builder().status(StatusCode::OK);
        for (key, value) in create_cors_headers() {
            builder = builder.header(key, value);
        }
        return Ok(builder.body("".to_string())?);
    }

    // Get query parameters
    let query_params = event.query_string_parameters();
    let query = query_params.first("query").unwrap_or("test");
    let test_type = query_params.first("test");

    // Handle explicit test requests
    if test_type == Some("connection") || query == "test" {
        return test_connection(pool).await;
    }

    // Handle other queries
    match query {
        "all_computers" => get_all_computers(pool).await,
        "manufacturers" => get_manufacturers(pool).await,
        "years" => get_years(pool).await,
        "cpus" => get_cpus(pool).await,
        "health" => health_check().await,
        _ => handle_unknown_query(query).await,
    }
}
