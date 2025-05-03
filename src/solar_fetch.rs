use chrono::DateTime;
use chrono::Utc;
use reqwest::Client;
use std::error::Error;

use crate::models::SolarLogRoot;
use crate::utils::parse_timestamp;

pub async fn fetch_solar_data(
    client: &Client,
    url: &str,
) -> Result<(DateTime<Utc>, i64, i64, i64, i64, i64, i64, i64), Box<dyn Error>> {
    let body = r#"{"801":{"170":null}}"#;

    let response = client
        .post(url)
        .header("Content-Type", "application/json")
        .body(body)
        .send()
        .await?;

    let text = response.text().await?;

    let parsed: SolarLogRoot = serde_json::from_str(&text)?;

    let timestamp_str = &parsed.inner.data.timestamp;
    let timestamp = parse_timestamp(timestamp_str)?;
    let pac = parsed.inner.data.pac;
    let pdc = parsed.inner.data.pdc;
    let uac = parsed.inner.data.uac;
    let udc = parsed.inner.data.udc;
    let yield_day = parsed.inner.data.yield_day;
    let cons_yield_day = parsed.inner.data.cons_yield_day;
    let cons_pac = parsed.inner.data.cons_pac;

    Ok((timestamp, pac, pdc, uac, udc, yield_day, cons_yield_day, cons_pac))
}
