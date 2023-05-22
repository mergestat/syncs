FROM meltano/meltano:v2.19.0-python3.11

RUN mkdir -p /syncer
COPY . /syncer/

LABEL com.mergestat.sync.clone="true"

ENTRYPOINT [ "/syncer/entrypoint.sh" ]
