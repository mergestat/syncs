FROM meltano/meltano:v2.19.0-python3.11

RUN mkdir -p /syncer
COPY . /syncer/

WORKDIR /syncer
RUN meltano install --clean

ENTRYPOINT [ "/syncer/entrypoint.sh" ]
