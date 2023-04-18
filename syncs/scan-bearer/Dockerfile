FROM golang:1.19-alpine3.16 AS builder

# install latest version of git, psql and jq
RUN apk upgrade && apk add --no-cache git postgresql-client jq build-base

RUN mkdir -p /syncer
COPY . /syncer/
RUN cd /syncer && ./install-bearer.sh

LABEL com.mergestat.sync.clone="true"

ENTRYPOINT [ "/syncer/entrypoint.sh" ]
