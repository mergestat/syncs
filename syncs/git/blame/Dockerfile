FROM python:3-alpine3.17

# install latest version of git, psql and jq
RUN apk upgrade && apk add --no-cache git postgresql-client jq

COPY . .
ENTRYPOINT [ "/entrypoint.sh" ]
