FROM golang:1.16-alpine AS confd

ENV GO111MODULE=auto
RUN  apk add --no-cache curl build-base && \
    curl -L -o /tmp/v0.16.0.tar.gz https://github.com/kelseyhightower/confd/archive/refs/tags/v0.16.0.tar.gz && \
    mkdir -p /go/src/github.com/kelseyhightower/confd && \
    cd /go/src/github.com/kelseyhightower/confd && \
    tar --strip-components=1 -zxf /tmp/v0.16.0.tar.gz && \
    go install github.com/kelseyhightower/confd

FROM alpine:3.16 AS otel
ARG APP_VERSION=0.55.0

RUN apk add --no-cache curl
RUN curl -L -o /tmp/otelcol-contrib_${APP_VERSION}_linux_386.apk https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v${APP_VERSION}/otelcol-contrib_${APP_VERSION}_linux_386.apk

FROM alpine:3.16
ARG APP_VERSION=0.55.0

COPY --from=otel /tmp/otelcol-contrib_${APP_VERSION}_linux_386.apk /tmp/otelcol-contrib_${APP_VERSION}_linux_386.apk
RUN apk update && apk add --no-cache shadow
RUN apk add --allow-untrusted /tmp/otelcol-contrib_${APP_VERSION}_linux_386.apk && \
    rm -f /tmp/otelcol-contrib_${APP_VERSION}_linux_386.apk && \
    mkdir -p /etc/otel

COPY --from=confd /go/bin/confd /usr/bin/confd
COPY confd/conf.d /etc/confd/conf.d
COPY confd/templates /etc/confd/templates
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "--config", "/etc/otel/config.yml" ]