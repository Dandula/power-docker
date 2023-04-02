#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"
DATABASE_DATA_DIR="${WORKSPACE_DIR}/data/databases/redis"
DUMPS_DIR="${WORKSPACE_DIR}/data/dumps/redis"
ENV_PATH="${WORKSPACE_DIR}/.env"

DC="${SCRIPT_DIR}/dc.sh"

# shellcheck source=scripts/parse_env.sh
. "${SCRIPT_DIR}/scripts/parse_env.sh"
# shellcheck source=scripts/statuses.sh
. "${SCRIPT_DIR}/scripts/statuses.sh"

DB_USER=$(parse_env "DB_USER" "${ENV_PATH}")
DB_PASSWORD=$(parse_env "DB_PASSWORD" "${ENV_PATH}")

SRC_DUMP_PATH="${DATABASE_DATA_DIR}/dump.rdb"

TIME=$(date +"%Y_%m_%d_%H%M%S")
DUMP_FILENAME="dump_${TIME}.rdb"
DST_DUMP_PATH="${DUMPS_DIR}/${DUMP_FILENAME}"

# shellcheck disable=SC2015
sudo -v \
  && cd "$WORKSPACE_DIR" \
  && ${DC} exec -T redis sh -c 'redis-cli --raw save' \
  && sudo cp "$SRC_DUMP_PATH" "$DST_DUMP_PATH" \
  && sudo chown $(whoami):$(whoami) "$DST_DUMP_PATH" \
  && message_success "Redis dump of database created $DST_DUMP_PATH" \
  || message_failure "Error creating the database Redis dump"