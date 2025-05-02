use chrono::{DateTime, Duration as ChronoDuration, Local, NaiveDateTime, Timelike, Utc};

pub fn calculate_next_collection_time() -> DateTime<Local> {
    let now = Local::now();
    let current_second = now.second();

    let next = if current_second < 40 && current_second >= 10 {
        now + ChronoDuration::seconds(40 - current_second as i64)
    } else if current_second < 10 {
        now + ChronoDuration::seconds(10 - current_second as i64)
    } else {
        now + ChronoDuration::seconds(70 - current_second as i64)
    };

    next.with_nanosecond(0).unwrap()
}

pub fn parse_timestamp(timestamp: &str) -> Result<DateTime<Utc>, chrono::ParseError> {
    let naive_datetime = NaiveDateTime::parse_from_str(timestamp, "%d.%m.%y %H:%M:%S")?;

    Ok(DateTime::from_naive_utc_and_offset(naive_datetime, Utc))
}
