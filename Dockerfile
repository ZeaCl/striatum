FROM hexpm/elixir:1.18.3-erlang-27.3.3-alpine-3.21.3 AS builder
RUN apk add --no-cache build-base git
WORKDIR /app
RUN mix local.hex --force && mix local.rebar --force
ENV MIX_ENV=prod
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
COPY config ./config
COPY lib ./lib
COPY priv ./priv
RUN mix deps.compile
RUN mix compile
RUN mix release striatum

FROM hexpm/elixir:1.18.3-erlang-27.3.3-alpine-3.21.3
RUN apk add --no-cache bash nodejs npm
WORKDIR /app
COPY --from=builder /app/_build/prod/rel/striatum ./
COPY start.sh /start.sh
RUN chmod +x /start.sh
EXPOSE 4086
ENV HOME=/app PORT=4086 MIX_ENV=prod SHELL=/bin/bash
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD wget --spider -q http://localhost:4086/health || exit 1
CMD ["/start.sh"]
