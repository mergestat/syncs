FROM debian:buster-slim

RUN apt-get update && apt-get install -y git postgresql-client jq

RUN mkdir -p /syncer
COPY schema.sql entrypoint.sh /syncer/

ENTRYPOINT [ "/syncer/entrypoint.sh" ]