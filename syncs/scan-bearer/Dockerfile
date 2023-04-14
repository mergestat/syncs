FROM bearer/bearer:1.3.1 AS bearer
FROM alpine:3.17.3

COPY --from=bearer /usr/local/bin/bearer /usr/local/bin/bearer

# install latest version of git, psql and jq
RUN apk upgrade && apk add --no-cache git postgresql-client jq

RUN mkdir -p /syncer
COPY . /syncer/

LABEL com.mergestat.sync.clone="true"

ENTRYPOINT [ "/syncer/entrypoint.sh" ]
