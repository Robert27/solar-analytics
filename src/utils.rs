use chrono::{DateTime, Duration as ChronoDuration, Local, NaiveDateTime, TimeZone, Timelike, Utc};
use chrono_tz::Europe::Berlin;

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

    let berlin_dt = Berlin
        .from_local_datetime(&naive_datetime)
        .single()
        .expect("ambiguous Berlin datetime");

    let utc_dt = berlin_dt.with_timezone(&Utc);

    Ok(utc_dt)
}
