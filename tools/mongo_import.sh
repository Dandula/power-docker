#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"
DUMPS_DIR="${WORKSPACE_DIR}/data/dumps/mongo"
ENV_PATH="${WORKSPACE_DIR}/.env"

DC="${SCRIPT_DIR}/dc.sh"

# shellcheck source=scripts/parse_env.sh
. "${SCRIPT_DIR}/scripts/parse_env.sh"
# shellcheck source=scripts/statuses.sh
. "${SCRIPT_DIR}/scripts/statuses.sh"

if [ -z "$1" ]; then
  read -r -p "Enter dump filename: " DUMP_FILENAME
else
  read -er -p "Enter dump filename: " -i "$1" DUMP_FILENAME
fi

DB_USER=$(parse_env "DB_USER" "${ENV_PATH}")
DB_PASSWORD=$(parse_env "DB_PASSWORD" "${ENV_PATH}")
DB_NAME=${DUMP_FILENAME%${DUMP_FILENAME:(-26)}}

DUMP_PATH="${DUMPS_DIR}/${DUMP_FILENAME}"

# shellcheck disable=SC2015
cd "$WORKSPACE_DIR" \
  && ${DC} exec -T mongo sh -c "exec mongorestore -u${DB_USER} -p${DB_PASSWORD} --authenticationDatabase=admin --archive" < "${DUMP_PATH}" \
  && message_success "Mongo database \`$DB_NAME\` restored from the dump $DUMP_PATH" \
  || message_failure "Error restoring from Mongo dump $DUMP_PATH"