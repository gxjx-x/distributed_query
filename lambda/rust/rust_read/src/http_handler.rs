use lambda_http::{http::StatusCode, Body, Error, Request, RequestExt, Response};
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

#[derive(Debug, FromRow)]
struct ManufacturerStats {
    name: String,
    country: Option<String>,
    computer_count: i64,
    first_system: Option<i32>,
    last_system: Option<i32>,
}

#[derive(Debug)]
struct YearStats {
    year: i32,
    systems_released: i64,
    avg_ram_kb: Option<i32>,
    max_ram_kb: i32,
    min_ram_kb: i32,
}


// Query computers using runtime checking (DSQL compatible)
async fn query_computers_runtime(pool: &Pool<Postgres>) -> Result<Response<String>> {
    println!("📊 Computers (using runtime query checking):");
    println!("{:-<80}", "");

    // Use query_as instead of query_as! for runtime checking
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
        LIMIT 15
        "#
    )
    .fetch_all(pool)
    .await?;

    let response = Response::builder()
        .status(StatusCode::OK)
        .header("Content-Type", "application/json")
        .body(serde_json::to_string(&computers).unwrap())
        .map_err(Box::new)?;
    Ok(response)

}

pub(crate) async fn function_handler(pool: &Pool<Postgres>, event: Request) -> Result<Response<String>, Error> {

    let computers = query_computers_runtime(pool).await.unwrap();
    Ok(computers)

    // // Extract some useful information from the request
    // let who = event
    //     .query_string_parameters_ref()
    //     .and_then(|params| params.first("name"))
    //     .unwrap_or("world");
    // let message = format!("Hello {who}, this is an AWS Lambda HTTP request");
    //
    // // Return something that implements IntoResponse.
    // // It will be serialized to the right response event automatically by the runtime
    // let resp = Response::builder()
    //     .status(200)
    //     .header("content-type", "text/html")
    //     .body(message.into())
    //     .map_err(Box::new)?;
    // Ok(resp)
}
