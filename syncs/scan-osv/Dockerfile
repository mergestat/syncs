FROM denoland/deno:alpine-1.32.5

# enable repository cloning
LABEL com.mergestat.sync.clone="true"

WORKDIR /app

# install osv-scanner from edge repository
RUN apk add --repository http://dl-4.alpinelinux.org/alpine/edge/community osv-scanner 

COPY . .
RUN deno cache main.ts

CMD ["run", "--allow-net", "--allow-env", "--allow-read", "--allow-run", "main.ts"]
