FROM rust:1.85-slim AS builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    pkg-config \
    libssl-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Cargo.toml ./
COPY Cargo.lock* ./

RUN mkdir -p src && \
    echo "fn main() {}" > src/main.rs && \
    cargo build --release && \
    rm -f target/release/deps/solar_analytics*

COPY . .

RUN cargo build --release

FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl3 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/solar_analytics /usr/local/bin/

RUN useradd -m appuser
USER appuser

ENV RUST_LOG=info

CMD ["solar_analytics"]