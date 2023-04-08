FROM golang:1.19-alpine3.16 AS builder
RUN set -x && apk add --no-cache git postgresql-client jq

RUN mkdir -p /syncer
COPY . /syncer/
RUN cd /syncer/blame && go build -o /bin/git-blame-to-csv

LABEL com.mergestat.sync.clone="true"

ENTRYPOINT [ "/syncer/entrypoint.sh" ]
