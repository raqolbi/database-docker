FROM alpine:3.20

# Install PgBouncer and required tools
RUN apk add --no-cache \
    pgbouncer \
    bash \
    ca-certificates \
    coreutils \
    su-exec

# --------------------------------------------------
# Create dedicated non-root user for PgBouncer
# --------------------------------------------------
RUN addgroup -S pgbouncer && adduser -S pgbouncer -G pgbouncer

# --------------------------------------------------
# Prepare directories
# --------------------------------------------------
RUN mkdir -p /etc/pgbouncer /var/log/pgbouncer \
 && chown -R pgbouncer:pgbouncer /etc/pgbouncer /var/log/pgbouncer

WORKDIR /etc/pgbouncer

# --------------------------------------------------
# Copy entrypoint
# --------------------------------------------------
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 6432

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/etc/pgbouncer/pgbouncer.ini"]
