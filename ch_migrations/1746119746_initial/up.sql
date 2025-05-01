CREATE DATABASE IF NOT EXISTS solar;

CREATE TABLE IF NOT EXISTS measurements
(
    timestamp DateTime,
    production Int64,
    consumption Int64
) ENGINE = MergeTree()
ORDER BY timestamp;