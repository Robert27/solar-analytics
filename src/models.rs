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
    #[serde(rename = "101")]
    pub production: i64,
    #[serde(rename = "110")]
    pub consumption: i64,
}
