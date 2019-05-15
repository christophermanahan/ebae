# ./Dockerfile

FROM elixir:1.8.1

RUN apt-get update && \
  apt-get install -y postgresql-client && \
  curl -sL https://deb.nodesource.com/setup_12.x | bash &&\
  apt-get install -y nodejs && \
  apt-get install -y inotify-tools && \
  npm install -g webpack-cli webpack

WORKDIR /app
COPY . .

RUN mix local.hex --force

RUN mix local.rebar --force

RUN mix deps.get

RUN mix do compile

CMD ["/app/entrypoint.sh"]
