use lambda_http::{http::StatusCode, Error, Request, RequestExt, Response};
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use std::collections::HashMap;
use tokio_postgres::Row;
use crate::AppState;

// Computer struct matching our database schema
#[derive(Debug, Serialize, Deserialize)]
struct Computer {
    id: Uuid,
    model: String,
    manufacturer: String,
    year: i32,
    cpu: String,
    ram_kb: i32,
    storage: String,
}

impl Computer {
    fn from_row(row: &Row) -> Self {
        Computer {
            id: row.get("id"),
            model: row.get("model"),
            manufacturer: row.get("manufacturer"),
            year: row.get("year"),
            cpu: row.get("cpu"),
            ram_kb: row.get("ram_kb"),
            storage: row.get("storage"),
        }
    }
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
    #[serde(skip_serializing_if = "Option::is_none")]
    database_version: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    tables: Option<Vec<String>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    connection_info: Option<serde_json::Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pool_stats: Option<serde_json::Value>,
}

fn create_cors_headers() -> Vec<(&'static str, &'static str)> {
    vec![
        ("Content-Type", "application/json"),
        ("Access-Control-Allow-Origin", "*"),
        ("Access-Control-Allow-Methods", "GET, POST, OPTIONS"),
        ("Access-Control-Allow-Headers", "Content-Type"),
    ]
}

async fn get_all_computers(app_state: &AppState) -> Result<Response<String>, Error> {
    let conn = app_state.pool.get().await.map_err(|e| {
        println!("Failed to get connection from BB8 pool: {:?}", e);
        Error::from(format!("Connection pool error: {}", e))
    })?;

    let rows = conn.query(
        "SELECT id, model, manufacturer, year, cpu, ram_kb, storage FROM computers ORDER BY year, manufacturer",
        &[]
    ).await.map_err(|e| {
        println!("Database query error: {:?}", e);
        Error::from(format!("Database error: {}", e))
    })?;

    let computers: Vec<Computer> = rows.iter().map(Computer::from_row).collect();

    let response = ApiResponse {
        status: "success".to_string(),
        message: Some("Computers data retrieved successfully using BB8 connection pool".to_string()),
        count: Some(computers.len()),
        data: Some(computers),
        manufacturers: None,
        years: None,
        cpus: None,
        database_version: None,
        tables: None,
        connection_info: None,
        pool_stats: None,
    };

    let json_response = serde_json::to_string(&response)?;
    let mut response_builder = Response::builder().status(StatusCode::OK);
    
    for (key, value) in create_cors_headers() {
        response_builder = response_builder.header(key, value);
    }
    
    Ok(response_builder.body(json_response)?)
}

async fn get_manufacturers(app_state: &AppState) -> Result<Response<String>, Error> {
    let conn = app_state.pool.get().await.map_err(|e| {
        Error::from(format!("Connection pool error: {}", e))
    })?;

    let rows = conn.query(
        "SELECT DISTINCT manufacturer FROM computers ORDER BY manufacturer",
        &[]
    ).await.map_err(|e| {
        Error::from(format!("Database error: {}", e))
    })?;

    let manufacturers: Vec<String> = rows.iter().map(|row| row.get("manufacturer")).collect();

    let response: ApiResponse<Vec<Computer>> = ApiResponse {
        status: "success".to_string(),
        message: Some("Manufacturers retrieved successfully".to_string()),
        count: Some(manufacturers.len()),
        data: None,
        manufacturers: Some(manufacturers),
        years: None,
        cpus: None,
        database_version: None,
        tables: None,
        connection_info: None,
        pool_stats: None,
    };

    let json_response = serde_json::to_string(&response)?;
    let mut response_builder = Response::builder().status(StatusCode::OK);
    
    for (key, value) in create_cors_headers() {
        response_builder = response_builder.header(key, value);
    }
    
    Ok(response_builder.body(json_response)?)
}

async fn get_years(app_state: &AppState) -> Result<Response<String>, Error> {
    let conn = app_state.pool.get().await.map_err(|e| {
        Error::from(format!("Connection pool error: {}", e))
    })?;

    let rows = conn.query(
        "SELECT DISTINCT year FROM computers ORDER BY year",
        &[]
    ).await.map_err(|e| {
        Error::from(format!("Database error: {}", e))
    })?;

    let years: Vec<i32> = rows.iter().map(|row| row.get("year")).collect();

    let response: ApiResponse<Vec<Computer>> = ApiResponse {
        status: "success".to_string(),
        message: Some("Years retrieved successfully".to_string()),
        count: Some(years.len()),
        data: None,
        manufacturers: None,
        years: Some(years),
        cpus: None,
        database_version: None,
        tables: None,
        connection_info: None,
        pool_stats: None,
    };

    let json_response = serde_json::to_string(&response)?;
    let mut response_builder = Response::builder().status(StatusCode::OK);
    
    for (key, value) in create_cors_headers() {
        response_builder = response_builder.header(key, value);
    }
    
    Ok(response_builder.body(json_response)?)
}

async fn get_cpus(app_state: &AppState) -> Result<Response<String>, Error> {
    let conn = app_state.pool.get().await.map_err(|e| {
        Error::from(format!("Connection pool error: {}", e))
    })?;

    let rows = conn.query(
        "SELECT DISTINCT cpu FROM computers ORDER BY cpu",
        &[]
    ).await.map_err(|e| {
        Error::from(format!("Database error: {}", e))
    })?;

    let cpus: Vec<String> = rows.iter().map(|row| row.get("cpu")).collect();

    let response: ApiResponse<Vec<Computer>> = ApiResponse {
        status: "success".to_string(),
        message: Some("CPUs retrieved successfully".to_string()),
        count: Some(cpus.len()),
        data: None,
        manufacturers: None,
        years: None,
        cpus: Some(cpus),
        database_version: None,
        tables: None,
        connection_info: None,
        pool_stats: None,
    };

    let json_response = serde_json::to_string(&response)?;
    let mut response_builder = Response::builder().status(StatusCode::OK);
    
    for (key, value) in create_cors_headers() {
        response_builder = response_builder.header(key, value);
    }
    
    Ok(response_builder.body(json_response)?)
}

async fn test_connection(app_state: &AppState) -> Result<Response<String>, Error> {
    let conn = app_state.pool.get().await.map_err(|e| {
        println!("Failed to get connection from BB8 pool: {:?}", e);
        Error::from(format!("Connection pool error: {}", e))
    })?;

    // Test basic connectivity
    let version_rows = conn.query("SELECT version()", &[]).await.map_err(|e| {
        Error::from(format!("Database error: {}", e))
    })?;
    
    let database_version = if let Some(row) = version_rows.first() {
        row.get::<_, String>(0)
    } else {
        "Unknown".to_string()
    };

    // Test if we can list tables
    let table_rows = conn.query(
        "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name",
        &[]
    ).await.map_err(|e| {
        Error::from(format!("Database error: {}", e))
    })?;

    let tables: Vec<String> = table_rows.iter().map(|row| row.get("table_name")).collect();

    let response: ApiResponse<Vec<Computer>> = ApiResponse {
        status: "success".to_string(),
        message: Some("Connection test successful using BB8 pool".to_string()),
        count: None,
        data: None,
        manufacturers: None,
        years: None,
        cpus: None,
        database_version: Some(database_version),
        tables: Some(tables),
        connection_info: Some(serde_json::json!({
            "user": "admin",
            "host": app_state.cluster_endpoint,
            "database": "postgres",
            "pool_type": "BB8"
        })),
        pool_stats: None,
    };

    let json_response = serde_json::to_string(&response)?;
    let mut response_builder = Response::builder().status(StatusCode::OK);
    
    for (key, value) in create_cors_headers() {
        response_builder = response_builder.header(key, value);
    }
    
    Ok(response_builder.body(json_response)?)
}

async fn get_pool_stats(app_state: &AppState) -> Result<Response<String>, Error> {
    let pool_stats = app_state.get_pool_stats();

    let response: ApiResponse<Vec<Computer>> = ApiResponse {
        status: "success".to_string(),
        message: Some("BB8 connection pool statistics".to_string()),
        count: None,
        data: None,
        manufacturers: None,
        years: None,
        cpus: None,
        database_version: None,
        tables: None,
        connection_info: None,
        pool_stats: Some(pool_stats),
    };

    let json_response = serde_json::to_string(&response)?;
    let mut response_builder = Response::builder().status(StatusCode::OK);
    
    for (key, value) in create_cors_headers() {
        response_builder = response_builder.header(key, value);
    }
    
    Ok(response_builder.body(json_response)?)
}

async fn search_computers(app_state: &AppState, search_term: &str) -> Result<Response<String>, Error> {
    let conn = app_state.pool.get().await.map_err(|e| {
        Error::from(format!("Connection pool error: {}", e))
    })?;

    let search_pattern = format!("%{}%", search_term);
    let rows = conn.query(
        "SELECT id, model, manufacturer, year, cpu, ram_kb, storage 
         FROM computers 
         WHERE LOWER(model) LIKE LOWER($1) OR LOWER(manufacturer) LIKE LOWER($1)
         ORDER BY year, manufacturer, model",
        &[&search_pattern]
    ).await.map_err(|e| {
        Error::from(format!("Database error: {}", e))
    })?;

    let computers: Vec<Computer> = rows.iter().map(Computer::from_row).collect();

    let response = ApiResponse {
        status: "success".to_string(),
        message: Some(format!("Search completed for term: {}", search_term)),
        count: Some(computers.len()),
        data: Some(computers),
        manufacturers: None,
        years: None,
        cpus: None,
        database_version: None,
        tables: None,
        connection_info: None,
        pool_stats: None,
    };

    let json_response = serde_json::to_string(&response)?;
    let mut response_builder = Response::builder().status(StatusCode::OK);
    
    for (key, value) in create_cors_headers() {
        response_builder = response_builder.header(key, value);
    }
    
    Ok(response_builder.body(json_response)?)
}

async fn filter_by_manufacturer(app_state: &AppState, manufacturer: &str) -> Result<Response<String>, Error> {
    let conn = app_state.pool.get().await.map_err(|e| {
        Error::from(format!("Connection pool error: {}", e))
    })?;

    let rows = conn.query(
        "SELECT id, model, manufacturer, year, cpu, ram_kb, storage 
         FROM computers 
         WHERE manufacturer = $1
         ORDER BY year, model",
        &[&manufacturer]
    ).await.map_err(|e| {
        Error::from(format!("Database error: {}", e))
    })?;

    let computers: Vec<Computer> = rows.iter().map(Computer::from_row).collect();

    let response = ApiResponse {
        status: "success".to_string(),
        message: Some(format!("Computers filtered by manufacturer: {}", manufacturer)),
        count: Some(computers.len()),
        data: Some(computers),
        manufacturers: None,
        years: None,
        cpus: None,
        database_version: None,
        tables: None,
        connection_info: None,
        pool_stats: None,
    };

    let json_response = serde_json::to_string(&response)?;
    let mut response_builder = Response::builder().status(StatusCode::OK);
    
    for (key, value) in create_cors_headers() {
        response_builder = response_builder.header(key, value);
    }
    
    Ok(response_builder.body(json_response)?)
}

async fn filter_by_year(app_state: &AppState, year: i32) -> Result<Response<String>, Error> {
    let conn = app_state.pool.get().await.map_err(|e| {
        Error::from(format!("Connection pool error: {}", e))
    })?;

    let rows = conn.query(
        "SELECT id, model, manufacturer, year, cpu, ram_kb, storage 
         FROM computers 
         WHERE year = $1
         ORDER BY manufacturer, model",
        &[&year]
    ).await.map_err(|e| {
        Error::from(format!("Database error: {}", e))
    })?;

    let computers: Vec<Computer> = rows.iter().map(Computer::from_row).collect();

    let response = ApiResponse {
        status: "success".to_string(),
        message: Some(format!("Computers filtered by year: {}", year)),
        count: Some(computers.len()),
        data: Some(computers),
        manufacturers: None,
        years: None,
        cpus: None,
        database_version: None,
        tables: None,
        connection_info: None,
        pool_stats: None,
    };

    let json_response = serde_json::to_string(&response)?;
    let mut response_builder = Response::builder().status(StatusCode::OK);
    
    for (key, value) in create_cors_headers() {
        response_builder = response_builder.header(key, value);
    }
    
    Ok(response_builder.body(json_response)?)
}

async fn filter_by_cpu(app_state: &AppState, cpu: &str) -> Result<Response<String>, Error> {
    let conn = app_state.pool.get().await.map_err(|e| {
        Error::from(format!("Connection pool error: {}", e))
    })?;

    let rows = conn.query(
        "SELECT id, model, manufacturer, year, cpu, ram_kb, storage 
         FROM computers 
         WHERE cpu = $1
         ORDER BY year, manufacturer",
        &[&cpu]
    ).await.map_err(|e| {
        Error::from(format!("Database error: {}", e))
    })?;

    let computers: Vec<Computer> = rows.iter().map(Computer::from_row).collect();

    let response = ApiResponse {
        status: "success".to_string(),
        message: Some(format!("Computers filtered by CPU: {}", cpu)),
        count: Some(computers.len()),
        data: Some(computers),
        manufacturers: None,
        years: None,
        cpus: None,
        database_version: None,
        tables: None,
        connection_info: None,
        pool_stats: None,
    };

    let json_response = serde_json::to_string(&response)?;
    let mut response_builder = Response::builder().status(StatusCode::OK);
    
    for (key, value) in create_cors_headers() {
        response_builder = response_builder.header(key, value);
    }
    
    Ok(response_builder.body(json_response)?)
}

pub async fn function_handler(app_state: AppState, event: Request) -> Result<Response<String>, Error> {
    println!("Processing request with BB8 connection pool");
    
    // Handle CORS preflight requests
    if event.method() == "OPTIONS" {
        let mut response_builder = Response::builder().status(StatusCode::OK);
        for (key, value) in create_cors_headers() {
            response_builder = response_builder.header(key, value);
        }
        return Ok(response_builder.body("".to_string())?);
    }

    // Parse query parameters
    let query_params: HashMap<String, String> = event
        .query_string_parameters()
        .iter()
        .map(|(k, v)| (k.to_string(), v.to_string()))
        .collect();

    let query = query_params.get("query").map(|s| s.as_str()).unwrap_or("test");

    println!("Processing query: {}", query);

    match query {
        "test" => test_connection(&app_state).await,
        "all_computers" => get_all_computers(&app_state).await,
        "manufacturers" => get_manufacturers(&app_state).await,
        "years" => get_years(&app_state).await,
        "cpus" => get_cpus(&app_state).await,
        "pool_stats" => get_pool_stats(&app_state).await,
        q if q.starts_with("search:") => {
            let search_term = &q[7..]; // Remove "search:" prefix
            search_computers(&app_state, search_term).await
        },
        q if q.starts_with("manufacturer:") => {
            let manufacturer = &q[13..]; // Remove "manufacturer:" prefix
            filter_by_manufacturer(&app_state, manufacturer).await
        },
        q if q.starts_with("year:") => {
            let year_str = &q[5..]; // Remove "year:" prefix
            match year_str.parse::<i32>() {
                Ok(year) => filter_by_year(&app_state, year).await,
                Err(_) => {
                    let response: ApiResponse<Vec<Computer>> = ApiResponse {
                        status: "error".to_string(),
                        message: Some("Invalid year format. Use year:YYYY".to_string()),
                        count: None,
                        data: None,
                        manufacturers: None,
                        years: None,
                        cpus: None,
                        database_version: None,
                        tables: None,
                        connection_info: None,
                        pool_stats: None,
                    };
                    let json_response = serde_json::to_string(&response)?;
                    let mut response_builder = Response::builder().status(StatusCode::BAD_REQUEST);
                    for (key, value) in create_cors_headers() {
                        response_builder = response_builder.header(key, value);
                    }
                    Ok(response_builder.body(json_response)?)
                }
            }
        },
        q if q.starts_with("cpu:") => {
            let cpu = &q[4..]; // Remove "cpu:" prefix
            filter_by_cpu(&app_state, cpu).await
        },
        "health" => {
            let pool_stats = app_state.get_pool_stats();
            let response: ApiResponse<Vec<Computer>> = ApiResponse {
                status: "healthy".to_string(),
                message: Some("Rust Lambda with BB8 connection pooling".to_string()),
                count: None,
                data: None,
                manufacturers: None,
                years: None,
                cpus: None,
                database_version: None,
                tables: None,
                connection_info: Some(serde_json::json!({
                    "service": "distributed-query-rust",
                    "version": "2.1.0-bb8",
                    "pool_type": "BB8",
                    "database": "connected"
                })),
                pool_stats: Some(pool_stats),
            };
            let json_response = serde_json::to_string(&response)?;
            let mut response_builder = Response::builder().status(StatusCode::OK);
            for (key, value) in create_cors_headers() {
                response_builder = response_builder.header(key, value);
            }
            Ok(response_builder.body(json_response)?)
        },
        _ => {
            let response: ApiResponse<Vec<Computer>> = ApiResponse {
                status: "success".to_string(),
                message: Some(format!("Query type '{}' is ready for implementation", query)),
                count: None,
                data: None,
                manufacturers: None,
                years: None,
                cpus: None,
                database_version: None,
                tables: None,
                connection_info: Some(serde_json::json!({
                    "available_queries": [
                        "test", "all_computers", "manufacturers", "years", "cpus", "health", "pool_stats",
                        "manufacturer:NAME", "year:YYYY", "cpu:ARCH", "search:TERM"
                    ],
                    "query_received": query,
                    "version": "2.1.0-bb8",
                    "pool_type": "BB8"
                })),
                pool_stats: None,
            };
            let json_response = serde_json::to_string(&response)?;
            let mut response_builder = Response::builder().status(StatusCode::OK);
            for (key, value) in create_cors_headers() {
                response_builder = response_builder.header(key, value);
            }
            Ok(response_builder.body(json_response)?)
        }
    }
}
