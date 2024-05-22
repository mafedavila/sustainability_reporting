# Stage 1: Build stage
FROM ubuntu:20.04 AS builder

# Install wget and unzip
RUN apt-get update && apt-get install -y wget unzip

# Create a directory for data files
WORKDIR /data

# Copy CSV files to /data directory
COPY ./data/* /data/

# Stage 2: Final stage
FROM timescale/timescaledb:latest-pg12

# Copy data files from the builder stage
COPY --from=builder /data /data

# Copy init script to initialize database
COPY ./database/init.sql /docker-entrypoint-initdb.d/

# Ensure init.sql is executable (if needed)
RUN chmod +x /docker-entrypoint-initdb.d/init.sql
