#!/bin/sh

echo "Outputting env vars for cron"
printenv > /etc/environment

echo "Starting cron for backups"
cron

docker-entrypoint.sh "$@"
