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
mix phx.digest
mix ecto.migrate

exec mix phx.server
