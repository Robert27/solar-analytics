use reqwest::Client;
use std::error::Error;

use crate::models::SolarLogRoot;

pub async fn fetch_solar_data(client: &Client, url: &str) -> Result<(i64, i64), Box<dyn Error>> {
    let body = r#"{"801":{"170":null}}"#;

    let response = client
        .post(url)
        .header("Content-Type", "application/json")
        .body(body)
        .send()
        .await?;

    let text = response.text().await?;

    let parsed: SolarLogRoot = serde_json::from_str(&text)?;

    let production = parsed.inner.data.production;
    let consumption = parsed.inner.data.consumption;

    Ok((production, consumption))
}
