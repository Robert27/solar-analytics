use chrono::{Local, Timelike};
use dotenv::dotenv;
use reqwest::Client;
use std::env;
use std::error::Error;
use tokio::time::{Duration, sleep};

mod models;
mod solar_fetch;
mod storage;
mod utils;

use solar_fetch::fetch_solar_data;
use storage::{create_clickhouse_client, store_measurement};
use utils::calculate_next_collection_time;

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

    log::info!("Starting solar data collection at strict :10 and :40 second marks");

    let mut next_collection = calculate_next_collection_time();
    log::info!("First collection scheduled at: {}", next_collection);

    loop {
        let now = Local::now();
        let wait_duration = (next_collection - now)
            .to_std()
            .unwrap_or(Duration::from_millis(10));

        if wait_duration > Duration::from_millis(100) {
            sleep(wait_duration - Duration::from_millis(100)).await;

            loop {
                let current = Local::now();
                if current >= next_collection {
                    break;
                }
                tokio::task::yield_now().await;
            }
        }

        let actual_collection_time = Local::now();
        log::debug!(
            "Collection triggered at {:02}:{:02}:{:02}.{:03} (target: {:02}:{:02}:{:02})",
            actual_collection_time.hour(),
            actual_collection_time.minute(),
            actual_collection_time.second(),
            actual_collection_time.nanosecond() / 1_000_000,
            next_collection.hour(),
            next_collection.minute(),
            next_collection.second()
        );

        next_collection = calculate_next_collection_time();

        match fetch_solar_data(&http_client, &url).await {
            Ok((timestamp, production, consumption)) => {
                match store_measurement(&db_client, timestamp, production, consumption).await {
                    Ok(_) => {
                        log::info!(
                            "Stored data with API timestamp {}: production: {}, consumption: {}",
                            timestamp,
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
