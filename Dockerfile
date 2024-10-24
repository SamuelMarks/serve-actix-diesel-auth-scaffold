FROM rustlang/rust:nightly-alpine

WORKDIR /src
COPY . .

# libpq-dev
RUN apk add --no-cache musl-dev postgresql16-dev
# && \
RUN cargo build --release

ENTRYPOINT ["cargo", "run"]
