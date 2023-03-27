FROM alpine:3.17

# install latest version of git, psql and jq
RUN apk upgrade && apk add --no-cache bash git postgresql-client jq github-cli

RUN mkdir -p /syncer
COPY schema.sql entrypoint.sh query.gql /syncer/

ENTRYPOINT [ "/syncer/entrypoint.sh" ]