FROM ubuntu:20.04 AS builder

RUN apt-get update && apt-get install -y wget unzip

WORKDIR /data

COPY ./data/* /data/

FROM timescale/timescaledb:latest-pg12

COPY --from=builder /data /data

COPY ./database/init.sql /docker-entrypoint-initdb.d/

RUN chmod +x /docker-entrypoint-initdb.d/init.sql
