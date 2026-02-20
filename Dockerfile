# Build stage
FROM rust:alpine AS builder

# Install musl-dev for static linking
RUN apk add --no-cache musl-dev

WORKDIR /app

# Copy the source code
COPY Cargo.toml Cargo.lock ./
COPY src ./src

# Build a statically linked binary
RUN cargo build --release

# Final stage - base image from scratch
FROM scratch AS base

# Copy the statically linked binary
COPY --from=builder /app/target/release/sidestore-vpn /sidestore-vpn

# Set the entrypoint
ENTRYPOINT ["/sidestore-vpn"]

# Tailscale image
FROM tailscale/tailscale:stable AS tailscale
ENV TS_ROUTES=10.7.0.1/32
ENV TS_SOCKET=/var/run/tailscale/tailscaled.sock
ENV TS_STATE_DIR=/var/lib/tailscale
COPY --from=base /sidestore-vpn /sidestore-vpn
COPY tailscale-entrypoint.sh /tailscale-entrypoint.sh
RUN chmod +x /tailscale-entrypoint.sh
ENTRYPOINT ["/tailscale-entrypoint.sh"]

FROM base
