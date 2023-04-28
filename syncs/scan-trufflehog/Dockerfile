FROM trufflesecurity/trufflehog:3.33.0 AS trufflehog
# pull trufflesecurity/trufflehog:3.33.0


FROM denoland/deno:alpine-1.32.5

RUN apk add git
COPY --from=trufflehog /usr/bin/trufflehog /usr/local/bin/trufflehog

# enable repository cloning
LABEL com.mergestat.sync.clone="true"

WORKDIR /app

COPY . .
RUN deno cache main.ts

CMD ["run", "--allow-net", "--allow-env", "--allow-read", "--allow-run", "main.ts"]
