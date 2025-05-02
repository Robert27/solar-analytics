FROM --platform=$BUILDPLATFORM rust:1.86-slim AS builder

WORKDIR /app
COPY . .

RUN apt-get update && apt-get install -y \
    gcc-aarch64-linux-gnu \
    libc6-dev-arm64-cross \
    pkg-config \
    build-essential \
    ca-certificates \
    curl

RUN dpkg --add-architecture arm64 && \
    apt-get update && \
    apt-get install -y libssl-dev libssl-dev:arm64

ENV \
  CC_aarch64_unknown_linux_gnu=aarch64-linux-gnu-gcc \
  CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc \
  OPENSSL_DIR=/usr/lib/aarch64-linux-gnu \
  OPENSSL_LIB_DIR=/usr/lib/aarch64-linux-gnu \
  OPENSSL_INCLUDE_DIR=/usr/include

ARG TARGETPLATFORM
RUN rustup target add aarch64-unknown-linux-gnu

RUN cargo build --release --target=aarch64-unknown-linux-gnu

FROM debian:stable-slim
WORKDIR /app

RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/aarch64-unknown-linux-gnu/release/solar_analytics .

CMD ["./solar_analytics"]