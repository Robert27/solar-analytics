CREATE DATABASE IF NOT EXISTS solar;

CREATE TABLE IF NOT EXISTS measurements
(
    timestamp DateTime,
    pac Int64,
    pdc Int64,
    uac Int64,
    udc Int64,
    consPac Int64,
    yieldDay Int64,
    consYieldDay Int64,
) ENGINE = MergeTree()
ORDER BY timestamp;