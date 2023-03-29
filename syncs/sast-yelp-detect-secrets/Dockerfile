FROM python:3-alpine3.17

# install latest version of git, psql and jq
RUN apk upgrade && apk add --no-cache git postgresql-client jq

# install python3 and yelp detect-secrets
ENV PYTHONUNBUFFERED=1
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools
RUN pip3 install detect-secrets

RUN mkdir -p /syncer
COPY . /syncer/

ENTRYPOINT [ "/syncer/entrypoint.sh" ]
