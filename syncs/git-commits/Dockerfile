FROM python:3-alpine3.17

# install latest version of git, psql and jq
RUN apk upgrade && apk add --no-cache git postgresql-client jq

# install json-cli (https://github.com/kellyjonbrazil/jc)
# this is used to parse log output of different tools and convert them into json
RUN pip3 install jc 

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
