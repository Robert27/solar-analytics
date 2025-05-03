use clickhouse::Client as ClickhouseClient;
use std::error::Error;

pub async fn store_measurement(
    db_client: &ClickhouseClient,
    timestamp: chrono::DateTime<chrono::Utc>,
    pac: i64,
    pdc: i64,
    uac: i64,
    udc: i64,
    yield_day: i64,
    cons_yield_day: i64,
    cons_pac: i64,
) -> Result<(), Box<dyn Error>> {
    let query = format!(
        "INSERT INTO measurements (timestamp, pac, pdc, uac, udc, yieldDay, consYieldDay, consPac) VALUES ('{}', {}, {}, {}, {}, {}, {}, {})",
        timestamp.format("%Y-%m-%d %H:%M:%S"),
        pac,
        pdc,
        uac,
        udc,
        yield_day,
        cons_yield_day,
        cons_pac
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
