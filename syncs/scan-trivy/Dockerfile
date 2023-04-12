FROM aquasec/trivy:0.39.1

# install latest version of git, psql and jq
RUN apk upgrade && apk add --no-cache git postgresql-client jq

RUN mkdir -p /syncer
COPY . /syncer/

ENTRYPOINT [ "/syncer/entrypoint.sh" ]
