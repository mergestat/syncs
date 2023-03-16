FROM alpine:3.17

# install latest version of git, psql and jq
RUN apk upgrade && apk add --no-cache git postgresql-client jq github-cli

COPY . .
ENTRYPOINT [ "/entrypoint.sh" ]
