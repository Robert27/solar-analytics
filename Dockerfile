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

# Option 2: Use a distroless image (uncomment to use instead of Alpine)
FROM gcr.io/distroless/cc-debian12 AS distroless

COPY --from=builder /app/target/release/solar_analytics /usr/local/bin/

ENV RUST_LOG=info

USER nonroot
CMD ["solar_analytics"]

