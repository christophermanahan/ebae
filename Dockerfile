# ./Dockerfile

# Extend from the official Elixir image
FROM elixir:latest

RUN apt-get update && \
  apt-get install -y postgresql-client && \
  curl -sL https://deb.nodesource.com/setup_12.x | bash &&\
  apt-get install -y nodejs &&\
  apt-get install -y inotify-tools

# Create app directory and copy the Elixir projects into it
RUN mkdir /app
COPY . /app
WORKDIR /app

# Install hex package manager
# By using --force, we don't need to type "Y" to confirm the installation
RUN mix local.hex --force

# Install rebar
RUN mix local.rebar --force

# Get dependencies
RUN mix deps.get

# Compile the project
RUN mix do compile

CMD ["/app/entrypoint.sh"]
