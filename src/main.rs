use chrono::Timelike;
use dotenv::dotenv;
use reqwest::Client;
use std::env;
use std::error::Error;
use tokio::time::{Duration, sleep};

mod models;
mod solar_fetch;
mod storage;

use solar_fetch::fetch_solar_data;
use storage::{create_clickhouse_client, store_measurement};

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    dotenv().ok();
    env_logger::init();

    let ip_address = env::var("SOLAR_LOG_IP").expect("SOLAR_LOG_IP must be set in .env file");
    let url = format!("http://{}/getjp", ip_address);

    let http_client = Client::new();

    let clickhouse_url =
        env::var("CLICKHOUSE_URL").expect("CLICKHOUSE_URL must be set in .env file");
    let username = env::var("CLICKHOUSE_USER").expect("CLICKHOUSE_USER must be set in .env file");
    let password =
        env::var("CLICKHOUSE_PASSWORD").expect("CLICKHOUSE_PASSWORD must be set in .env file");
    let database = env::var("CLICKHOUSE_DB").expect("CLICKHOUSE_DB must be set in .env file");

    let db_client = create_clickhouse_client(clickhouse_url, username, password, database);

    log::info!("Starting solar data collection with synchronized timing at the top of each minute");

    loop {
        let now = chrono::Local::now();

        let seconds_to_next_minute = 60 - now.second() as u64;
        let nanos_remaining = 1_000_000_000 - now.nanosecond() as u64;
        let wait_duration =
            Duration::from_secs(seconds_to_next_minute) - Duration::from_nanos(nanos_remaining);

        sleep(wait_duration).await;

        match fetch_solar_data(&http_client, &url).await {
            Ok((production, consumption)) => {
                let timestamp = chrono::Utc::now();

                match store_measurement(&db_client, timestamp, production, consumption).await {
                    Ok(_) => {
                        log::info!(
                            "Stored data: production: {}, consumption: {}",
                            production,
                            consumption
                        );
                    }
                    Err(e) => log::error!("Failed to store data in database: {}", e),
                }
            }
            Err(e) => log::error!("Failed to fetch solar data: {}", e),
        }
    }
}
