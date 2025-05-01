# Solar Analytics

A Rust application for retrieving and analyzing data from a SolarLog device.

## Overview

Solar Analytics connects to a SolarLog device on your local network, retrieves current power production and consumption data, and logs it for analysis. The application uses a simple HTTP POST request to fetch data from the SolarLog API endpoint.

## Features

- Fetch real-time solar production and consumption data
- Configurable SolarLog IP address via environment variables
- Structured logging for easy monitoring

## Requirements

- Rust (latest stable version)
- A SolarLog device on your local network

## License

MIT