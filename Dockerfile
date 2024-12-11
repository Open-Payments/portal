# Node build stage for React application
FROM node:23-slim AS node-builder
WORKDIR /buildspace
COPY . .
WORKDIR /buildspace/portal-web
RUN npm ci
RUN npm run build


# Rust build stage
FROM rust:1.81-slim-bullseye AS rust-builder
WORKDIR /buildspace
COPY --from=node-builder /buildspace .
RUN cargo build --release


# Production stage
FROM debian:bullseye-slim
WORKDIR /usr/local/bin
COPY --from=rust-builder /buildspace/static ./static
COPY --from=rust-builder /buildspace/target/release/portal-api .
CMD ["./portal-api"]