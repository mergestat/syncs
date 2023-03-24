FROM golang:1.19-buster as builder

RUN apt-get update && apt-get -y install cmake libssl-dev git
RUN git clone --recurse-submodules https://github.com/mergestat/mergestat-lite.git && cd mergestat-lite && make libgit2 && make

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FROM debian:buster-slim

RUN apt-get update && apt-get install -y git postgresql-client jq

COPY --from=builder /go/mergestat-lite/.build/mergestat /usr/local/bin/mergestat

RUN mkdir -p /syncer
COPY schema.sql entrypoint.sh /syncer/

ENTRYPOINT [ "/syncer/entrypoint.sh" ]
