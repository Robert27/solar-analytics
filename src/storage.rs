use clickhouse::Client as ClickhouseClient;
use std::error::Error;

pub async fn store_measurement(
    db_client: &ClickhouseClient,
    timestamp: chrono::DateTime<chrono::Utc>,
    production: i64,
    consumption: i64,
) -> Result<(), Box<dyn Error>> {
    let query = format!(
        "INSERT INTO measurements (timestamp, production, consumption) VALUES ('{}', {}, {})",
        timestamp.format("%Y-%m-%d %H:%M:%S"),
        production,
        consumption
    );

    db_client.query(&query).execute().await?;

    Ok(())
}

pub fn create_clickhouse_client(
    url: String,
    username: String,
    password: String,
    database: String,
) -> ClickhouseClient {
    ClickhouseClient::default()
        .with_url(url)
        .with_user(username)
        .with_database(database)
        .with_password(password)
}
