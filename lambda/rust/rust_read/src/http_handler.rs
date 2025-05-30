use lambda_http::{http::StatusCode, Error, Request, RequestExt, Response};
use serde::{Deserialize, Serialize};
use sqlx::{prelude::FromRow, Pool, Postgres};
use uuid::Uuid;
use anyhow::Result;


// Define structs with FromRow derive for runtime mapping
#[derive(Debug, FromRow, Serialize, Deserialize)]
struct Computers {
    id: Uuid,
    model: String,
    manufacturer: String,
    year: i32,
    ram_kb: i32,
    cpu: String,
    storage: String,
    category: Option<String>,
}

#[derive(Debug, FromRow, Serialize)]
struct ManufacturerStats {
    name: String,
    country: Option<String>,
    computer_count: i64,
    first_system: Option<i32>,
    last_system: Option<i32>,
}

// Search result struct that combines data from multiple tables
#[derive(Debug, FromRow, Serialize, Deserialize)]
struct SearchResult {
    id: Uuid,
    model: String,
    manufacturer: String,
    year: i32,
    ram_kb: i32,
    cpu: String,
    storage: String,
    category: Option<String>,
    search_relevance_score: Option<f64>, // For ranking results
}

async fn weighted_search(pool: &Pool<Postgres>, search_term: &str) -> Result<Response<String>> {
    let results: Vec<SearchResult> = sqlx::query_as(
        r#"
        SELECT 
            c.id,
            c.model,
            m.name as manufacturer,
            c.year,
            c.ram_kb,
            cf.family_name as cpu,
            st.type_name as storage,
            cat.category_name as category,
            (
                CASE WHEN LOWER(c.model) LIKE LOWER($1) THEN 10 ELSE 0 END +
                CASE WHEN LOWER(m.name) LIKE LOWER($1) THEN 8 ELSE 0 END +
                CASE WHEN LOWER(cf.family_name) LIKE LOWER($1) THEN 6 ELSE 0 END +
                CASE WHEN LOWER(st.type_name) LIKE LOWER($1) THEN 3 ELSE 0 END +
                CASE WHEN LOWER(cat.category_name) LIKE LOWER($1) THEN 2 ELSE 0 END
            )::float8 as search_relevance_score
        FROM computers c
        JOIN manufacturers m ON c.manufacturer_id = m.id
        JOIN cpu_families cf ON c.cpu_family_id = cf.id
        JOIN storage_types st ON c.storage_type_id = st.id
        LEFT JOIN computer_categories cat ON c.category_id = cat.id
        WHERE 
            LOWER(c.model) LIKE LOWER($1) OR
            LOWER(m.name) LIKE LOWER($1) OR
            LOWER(cf.family_name) LIKE LOWER($1) OR
            LOWER(st.type_name) LIKE LOWER($1) OR
            LOWER(cat.category_name) LIKE LOWER($1)
        ORDER BY search_relevance_score DESC, c.year DESC
        "#
    )
    .bind(format!("%{}%", search_term))
    .fetch_all(pool)
    .await?;

    let response = Response::builder()
        .status(StatusCode::OK)
        .header("Content-Type", "application/json")
        // NOTE: CORS
        .header("Access-Control-Allow-Headers", "Content-Type")
        .header("Access-Control-Allow-Origin", "*")
        .header("Access-Control-Allow-Methods", "OPTIONS,POST,GET")
        .body(serde_json::to_string(&results).unwrap())
        .map_err(Box::new)?;
    Ok(response)
}

// Query computers using runtime checking (DSQL compatible)
async fn get_all_cpu_architectures(pool: &Pool<Postgres>) -> Result<Response<String>> {
    let cpus: Vec<String> = sqlx::query_scalar(
        r#"
        SELECT family_name FROM cpu_families ORDER BY family_name
        "#
    )
    .fetch_all(pool)
    .await?;

    let response = Response::builder()
        .status(StatusCode::OK)
        .header("Content-Type", "application/json")
        // NOTE: CORS
        .header("Access-Control-Allow-Headers", "Content-Type")
        .header("Access-Control-Allow-Origin", "*")
        .header("Access-Control-Allow-Methods", "OPTIONS,POST,GET")
        .body(serde_json::to_string(&cpus).unwrap())
        .map_err(Box::new)?;
    Ok(response)

}

// Query computers using runtime checking (DSQL compatible)
async fn query_computers_runtime(pool: &Pool<Postgres>) -> Result<Response<String>> {
    let computers: Vec<Computers> = sqlx::query_as(
        r#"
        SELECT 
            c.id,
            c.model,
            m.name as manufacturer,
            c.year,
            c.ram_kb,
            cf.family_name as cpu,
            st.type_name as storage,
            cat.category_name as category
        FROM computers c
        JOIN manufacturers m ON c.manufacturer_id = m.id
        JOIN cpu_families cf ON c.cpu_family_id = cf.id
        JOIN storage_types st ON c.storage_type_id = st.id
        LEFT JOIN computer_categories cat ON c.category_id = cat.id
        ORDER BY c.year, m.name, c.model
        --LIMIT 50
        "#
    )
    .fetch_all(pool)
    .await?;

    let response = Response::builder()
        .status(StatusCode::OK)
        .header("Content-Type", "application/json")
        // NOTE: CORS
        .header("Access-Control-Allow-Headers", "Content-Type")
        .header("Access-Control-Allow-Origin", "*")
        .header("Access-Control-Allow-Methods", "OPTIONS,POST,GET")
        .body(serde_json::to_string(&computers).unwrap())
        .map_err(Box::new)?;
    Ok(response)

}

// Query manufacturer stats using runtime checking
async fn query_manufacturer_stats_runtime(pool: &Pool<Postgres>) -> Result<Response<String>> {
    let stats: Vec<ManufacturerStats> = sqlx::query_as(
        r#"
        SELECT 
            m.name,
            m.country,
            COUNT(*) as computer_count,
            MIN(c.year) as first_system,
            MAX(c.year) as last_system
        FROM computers c
        JOIN manufacturers m ON c.manufacturer_id = m.id
        GROUP BY m.name, m.country
        ORDER BY computer_count DESC
        "#
    )
    .fetch_all(pool)
    .await?;

    let response = Response::builder()
        .status(StatusCode::OK)
        .header("Content-Type", "application/json")
        // NOTE: CORS
        .header("Access-Control-Allow-Headers", "Content-Type")
        .header("Access-Control-Allow-Origin", "*")
        .header("Access-Control-Allow-Methods", "OPTIONS,POST,GET")
        .body(serde_json::to_string(&stats).unwrap())
        .map_err(Box::new)?;
    Ok(response)
}

// Example of a parameterized query (DSQL compatible)
async fn find_computers_by_year(pool: &Pool<Postgres>, target_year: i32) -> Result<Response<String>> {
    let computers: Vec<Computers> = sqlx::query_as(
        r#"
        SELECT 
            c.id,
            c.model,
            m.name as manufacturer,
            c.year,
            c.ram_kb,
            cf.family_name as cpu,
            st.type_name as storage,
            cat.category_name as category
        FROM computers c
        JOIN manufacturers m ON c.manufacturer_id = m.id
        JOIN cpu_families cf ON c.cpu_family_id = cf.id
        JOIN storage_types st ON c.storage_type_id = st.id
        LEFT JOIN computer_categories cat ON c.category_id = cat.id
        WHERE c.year = $1
        ORDER BY m.name, c.model
        "#
    )
    .bind(target_year)
    .fetch_all(pool)
    .await?;
    let response = Response::builder()
        .status(StatusCode::OK)
        .header("Content-Type", "application/json")
        // NOTE: CORS
        .header("Access-Control-Allow-Headers", "Content-Type")
        .header("Access-Control-Allow-Origin", "*")
        .header("Access-Control-Allow-Methods", "OPTIONS,POST,GET")
        .body(serde_json::to_string(&computers).unwrap())
        .map_err(Box::new)?;

    Ok(response)
}
async fn find_computers_by_cpu(pool: &Pool<Postgres>, target_cpu: &str) -> Result<Response<String>> {
    let computers: Vec<Computers> = sqlx::query_as(
        r#"
        SELECT 
            c.id,
            c.model,
            m.name as manufacturer,
            c.year,
            c.ram_kb,
            cf.family_name as cpu,
            st.type_name as storage,
            cat.category_name as category
        FROM computers c
        JOIN manufacturers m ON c.manufacturer_id = m.id
        JOIN cpu_families cf ON c.cpu_family_id = cf.id
        JOIN storage_types st ON c.storage_type_id = st.id
        LEFT JOIN computer_categories cat ON c.category_id = cat.id
        WHERE cf.family_name = $1
        ORDER BY m.name, c.model
        "#
    )
    .bind(target_cpu)
    .fetch_all(pool)
    .await?;
    let response = Response::builder()
        .status(StatusCode::OK)
        .header("Content-Type", "application/json")
        // NOTE: CORS
        .header("Access-Control-Allow-Headers", "Content-Type")
        .header("Access-Control-Allow-Origin", "*")
        .header("Access-Control-Allow-Methods", "OPTIONS,POST,GET")
        .body(serde_json::to_string(&computers).unwrap())
        .map_err(Box::new)?;

    Ok(response)
}

pub(crate) async fn function_handler(pool: &Pool<Postgres>, event: Request) -> Result<Response<String>, Error> {

    // Extract some useful information from the request
    let what = event
        .query_string_parameters_ref()
        .and_then(|params| params.first("query"))
        .unwrap_or("all_computers");

    // Big boy match
    match what {
        "all_computers" => {
            let computers = query_computers_runtime(pool).await.unwrap();
            Ok(computers)
        },
        "manuf_stats" => {
            let manuf = query_manufacturer_stats_runtime(pool).await.unwrap();
            Ok(manuf)
        },
        "cpus" => {
            let cpus = get_all_cpu_architectures(pool).await.unwrap();
            Ok(cpus)
        },
        "year_stats" => {
            // Get the year from query string parameter and cast it into a i32 
            let year = event
                .query_string_parameters_ref()
                .and_then(|params| params.first("year"))
                .and_then(|y|y.parse::<i32>().ok())
                .unwrap_or(1988);

            let computers = find_computers_by_year(pool, year).await.unwrap();
            Ok(computers)
        },
        "cpu_computers" => {
            // Get the year from query string parameter and cast it into a i32 
            let cpu = event
                .query_string_parameters_ref()
                .and_then(|params| params.first("cpu"))
                .unwrap_or("Zilog Z80");

            let computers = find_computers_by_cpu(pool, cpu).await.unwrap();
            Ok(computers)
        },
        "search" => {
            // Get the year from query string parameter and cast it into a i32 
            let term = event
                .query_string_parameters_ref()
                .and_then(|params| params.first("term"))
                .unwrap_or("");

            let computers = weighted_search(pool, term).await.unwrap();
            Ok(computers)
        },
        _ => {
            let computers = query_computers_runtime(pool).await.unwrap();
            Ok(computers)
        },
    }
}
