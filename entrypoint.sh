#!/bin/bash
# Docker entrypoint script.

set -e

while ! pg_isready -q -h $PGHOST -p $PGPORT -U $PGUSER
do
  echo "$(date): Waiting for database to start"
  sleep 2
done

if psql ${DB_NAME} -c ''; 
then
  echo "Database $PGDATABASE started"
else
  echo "Creating database $PGDATABASE"
  createdb -E UTF8 $PGDATABASE -l en_US.UTF-8 -T template0
  echo "Database $PGDATABASE created"
fi

pushd assets
webpack --mode production 
popd

pushd deps/argon2_elixir
make clean && make
popd

mix phx.digest
mix ecto.migrate
mix run priv/repo/seeds.exs

exec mix phx.server
