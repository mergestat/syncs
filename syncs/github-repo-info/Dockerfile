FROM denoland/deno:1.32.3

WORKDIR /app

# Prefer not to run as root.
USER deno

COPY . .

# Compile the main app so that it doesn't need to be compiled each startup/entry.
RUN deno cache main.ts

CMD ["run", "--allow-net", "--allow-env", "--allow-read", "main.ts"]
