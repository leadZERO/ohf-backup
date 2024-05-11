FROM mcr.microsoft.com/devcontainers/base:alpine-3.19

ADD https://download.influxdata.com/influxdb/releases/influxdb2-client-2.7.5-linux-amd64.tar.gz /
RUN tar zxvf /influxdb2-client-2.7.5-linux-amd64.tar.gz && mv influx /bin/influx && chmod u+x /bin/influx
RUN apk add --update --no-cache mariadb-client

ENTRYPOINT [ "/bin/sh" ]