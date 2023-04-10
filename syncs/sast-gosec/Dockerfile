FROM golang:1.20-alpine3.17

# install latest version of psql and jq
RUN apk upgrade && apk add --no-cache curl postgresql-client jq

# install gosec binary to /usr/local/bin
# TODO(@riyaz): remove script piping and do manual checksum verification
RUN curl -sfL https://raw.githubusercontent.com/securego/gosec/master/install.sh | sh -s - -b /usr/local/bin v2.14.0

LABEL com.mergestat.sync.clone="true"

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
