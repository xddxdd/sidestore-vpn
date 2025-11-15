FROM rust:alpine AS builder
RUN apk add --no-cache \
  musl-dev \
  gcc \
  git \
  build-base \
  openssl-dev \
  perl

RUN rustup target add aarch64-unknown-linux-musl
WORKDIR /src
RUN git clone https://github.com/xddxdd/sidestore-vpn.git .
ENV OPENSSL_STATIC=1
ENV PKG_CONFIG_ALLOW_CROSS=1
RUN cargo build --release --target aarch64-unknown-linux-musl

FROM alpine
COPY --from=builder /src/target/aarch64-unknown-linux-musl/release/sidestore-vpn /usr/local/bin/sidestore-vpn
RUN chmod +x /usr/local/bin/sidestore-vpn
ENTRYPOINT [“/usr/local/bin/sidestore-vpn”]
