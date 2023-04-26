# start with deno base image to copy the binary from
FROM denoland/deno:bin-1.32.5 AS deno

# using Brakeman's official (alpine-based) image
# FROM presidentbeef/brakeman:v5.4.1

FROM frolvlad/alpine-glibc:alpine-3.17

# enable repository cloning
LABEL com.mergestat.sync.clone="true"

ENV NOKOGIRI_USE_SYSTEM_LIBRARIES=1

# install Ruby 2.7
RUN apk update \
  && apk add ruby ruby-bigdecimal ruby-io-console ruby-irb build-base ruby-dev less \
  && apk add --update-cache --repository http://dl-4.alpinelinux.org/alpine/edge/main ca-certificates libressl libressl-dev \
  && gem install bundler:'~> 1.0' json \
  && bundle config build.nokogiri --use-system-libraries \
  && bundle config git.allow_insecure true \
  && gem cleanup \
  && apk del build-base ruby-dev libressl-dev \
  && rm -rf /usr/lib/ruby/gems/*/cache/* /var/cache/apk/* /tmp/* /var/tmp/*

# install Brakeman v5.4.1
RUN gem install brakeman -v 5.4.1

WORKDIR /app

# copy deno binary from the base image
COPY --from=deno /deno /usr/local/bin/deno
COPY . .

# Compile the main app so that it doesn't need to be compiled each startup/entry.
RUN deno cache main.ts

ENTRYPOINT [ "/usr/local/bin/deno" ]
CMD ["run", "--allow-net", "--allow-env", "--allow-read", "--allow-run", "main.ts"]
