# Solar Analytics

A Rust microservice for collecting, storing, and analyzing solar power data from SolarLog devices.

## Overview

Solar Analytics is a lightweight microservice that:
1. Connects to a SolarLog device on your local network
2. Retrieves real-time solar production and consumption metrics
3. Stores the data in a ClickHouse database for persistence and analysis
4. Runs on a precise schedule, capturing data at the top of every minute

The application is designed to run as a containerized service, making it easy to deploy in any environment with Docker.

## Features

- Fetch real-time solar production and consumption data
- Store time-series data in ClickHouse for high-performance analytics
- Precisely synchronized data collection at minute intervals
- Configurable via environment variables
- Containerized for easy deployment
- Structured logging for monitoring

## Architecture

This microservice follows a simple but effective architecture:
- **Data Collection**: Uses the SolarLog HTTP API to fetch current production/consumption values
- **Storage**: Persists all measurements in a ClickHouse database with timestamp indexing
- **Scheduling**: Ensures measurements are taken at consistent intervals

## Configuration

The service is configured through environment variables:

| Variable | Description | Example |
|----------|-------------|---------|
| SOLAR_LOG_IP | IP address of your SolarLog device | 192.168.1.100 |
| CLICKHOUSE_URL | URL for ClickHouse database | http://clickhouse:8123 |
| CLICKHOUSE_USER | ClickHouse username | default |
| CLICKHOUSE_PASSWORD | ClickHouse password | password |
| CLICKHOUSE_DB | ClickHouse database name | solar |



## Development

```bash
# Clone the repository
git clone https://github.com/yourusername/solar-analytics.git

# Create and configure .env file
cp .env.example .env
# Edit .env with your configuration

# Run the application
cargo run
```

## License

MIT