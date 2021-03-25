#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"
DUMPS_DIR="${WORKSPACE_DIR}/data/dumps/mongo"
ENV_PATH="${WORKSPACE_DIR}/.env"

# shellcheck source=scripts/parse_env.sh
. "${SCRIPT_DIR}/scripts/parse_env.sh"
# shellcheck source=scripts/statuses.sh
. "${SCRIPT_DIR}/scripts/statuses.sh"

if [ -z "$1" ]; then
  read -r -p "Enter database name: " DB_NAME
else
  read -er -p "Enter database name: " -i "$1" DB_NAME
fi

DB_USER=$(parse_env "DB_USER" "${ENV_PATH}")
DB_PASSWORD=$(parse_env "DB_PASSWORD" "${ENV_PATH}")

TIME=$(date +"%Y_%m_%d_%H%M%S")
DUMP_FILENAME="${DB_NAME}_${TIME}.archive"
DUMP_PATH="${DUMPS_DIR}/${DUMP_FILENAME}"

# shellcheck disable=SC2015
cd "$WORKSPACE_DIR" \
  && docker-compose exec -T mongo sh -c "exec mongodump -u${DB_USER} -p${DB_PASSWORD} -d${DB_NAME} --authenticationDatabase=admin --archive" > "${DUMP_PATH}" \
  && message_success "Mongo dump of database \`${DB_NAME}\` created ${DUMP_PATH}" \
  || message_failure "Error creating the database \`${DB_NAME}\` Mongo dump"