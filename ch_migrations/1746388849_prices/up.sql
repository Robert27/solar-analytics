CREATE TABLE IF NOT EXISTS energy_selling_prices
(
    start_date Date,
    price_kwh Float64 COMMENT 'Selling price per kWh in Euro cents'
) ENGINE = MergeTree()
ORDER BY start_date;

CREATE TABLE IF NOT EXISTS energy_buying_prices
(
    start_date Date,
    base_price Float64 COMMENT 'Base price for buying energy in Euro',
    price_kwh Float64 COMMENT 'Price per kWh for buying energy in Euro cents'
) ENGINE = MergeTree()
ORDER BY start_date;