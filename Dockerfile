FROM --platform=amd64 ghcr.io/lobaro/restic-backup-docker:v1.3.2

LABEL org.opencontainers.image.source=https://github.com/leadzero/ohf-backup
LABEL org.opencontainers.image.description="Restic backup + Influx/MariaDB backup"

ADD https://download.influxdata.com/influxdb/releases/influxdb2-client-2.7.5-linux-amd64.tar.gz /
RUN tar zxvf /influxdb2-client-2.7.5-linux-amd64.tar.gz && mv influx /bin/influx && chmod u+x /bin/influx
RUN apk add --update --no-cache mariadb-client

ENV DB_BACKUP_ROOT="/data/db_backup"

ENV INFLUX_HOST=""
ENV INFLUX_ORG=""
ENV INFLUX_TOKEN=""
ENV INFLUX_BACKUP_EXTRA_OPTS=""


ENV MARIADB_USER=""
ENV MARIADB_PASS=""
ENV MARIADB_SERVER=""

COPY db_backup.sh /hooks/pre-backup.sh