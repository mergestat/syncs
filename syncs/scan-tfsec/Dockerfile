FROM aquasec/tfsec:v1.28 as tfsec

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FROM debian:buster-slim

RUN apt-get update && apt-get install -y git postgresql-client jq

COPY --from=tfsec /usr/bin/tfsec /usr/local/bin/tfsec

RUN mkdir -p /syncer
COPY schema.sql entrypoint.sh /syncer/

LABEL com.mergestat.sync.clone="true"

ENTRYPOINT [ "/syncer/entrypoint.sh" ]
