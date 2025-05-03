use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct SolarLogRoot {
    #[serde(rename = "801")]
    pub inner: Inner801,
}

#[derive(Debug, Deserialize)]
pub struct Inner801 {
    #[serde(rename = "170")]
    pub data: Data170,
}

#[derive(Debug, Deserialize)]
pub struct Data170 {
    #[serde(rename = "100")]
    pub timestamp: String,
    #[serde(rename = "101")]
    pub pac: i64,
    #[serde(rename = "102")]
    pub pdc: i64,
    #[serde(rename = "103")]
    pub uac: i64,
    #[serde(rename = "104")]
    pub udc: i64,
    #[serde(rename = "105")]
    pub yield_day: i64,
    #[serde(rename = "111")]
    pub cons_yield_day: i64,
    #[serde(rename = "110")]
    pub cons_pac: i64,
}
