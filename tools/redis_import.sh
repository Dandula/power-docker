#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"
REDIS_IMAGE_DIR="${WORKSPACE_DIR}/images/redis"
DATABASE_DATA_DIR="${WORKSPACE_DIR}/data/databases/redis"
DUMPS_DIR="${WORKSPACE_DIR}/data/dumps/redis"
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

CONFIG_PATH="${REDIS_IMAGE_DIR}/redis.conf"

SRC_DUMP_PATH="${DUMPS_DIR}/${DUMP_FILENAME}"
DST_DUMP_PATH="${DATABASE_DATA_DIR}/dump.rdb"

EXPECTED_OPTION_REGEX="appendonly\s*\(yes\|no\)"
EXPECTED_OPTION_ENABLE="appendonly yes"
EXPECTED_OPTION_DISABLE="appendonly no"

if grep -q "$EXPECTED_OPTION_REGEX" "$CONFIG_PATH"; then
  sudo -v

  OLD_EXPECTED_OPTION=$(grep "$EXPECTED_OPTION_REGEX" "$CONFIG_PATH")

  sed -i "s/${OLD_EXPECTED_OPTION}/${EXPECTED_OPTION_DISABLE}/g" "$CONFIG_PATH"

  # shellcheck disable=SC2015
  cd "$WORKSPACE_DIR" \
    && ${DC} stop redis \
    && sudo cp -f "$SRC_DUMP_PATH" "$DST_DUMP_PATH" \
    && ${DC} up -d redis \
    && DUMP_DIR_IN_CONTAINER=$(${DC} exec -T redis sh -c 'redis-cli CONFIG GET dir | tail -1') \
    && ${DC} exec -T redis sh -c "chown redis:redis ${DUMP_DIR_IN_CONTAINER}" \
    && message_success "Redis database restored from the dump $DUMP_PATH" \
    || message_failure "Error restoring from Redis dump $DUMP_PATH"

  sed -i "s/${EXPECTED_OPTION_DISABLE}/${OLD_EXPECTED_OPTION}/g" "$CONFIG_PATH"
else
  sudo -v

  echo "$EXPECTED_OPTION_DISABLE" >> "$CONFIG_PATH"

  sed -i "s/${EXPECTED_OPTION_ENABLE}/${EXPECTED_OPTION_DISABLE}/g" "$CONFIG_PATH"

  # shellcheck disable=SC2015
  cd "$WORKSPACE_DIR" \
    && ${DC} stop redis \
    && sudo cp -f "$SRC_DUMP_PATH" "$DST_DUMP_PATH" \
    && ${DC} up -d redis \
    && DUMP_DIR_IN_CONTAINER=$(${DC} exec -T redis sh -c 'redis-cli CONFIG GET dir | tail -1') \
    && ${DC} exec -T redis sh -c "chown redis:redis ${DUMP_DIR_IN_CONTAINER}" \
    && message_success "Redis database restored from the dump $DUMP_PATH" \
    || message_failure "Error restoring from Redis dump $DUMP_PATH"

  sed -i "/$EXPECTED_OPTION_ENABLE/d" "$CONFIG_PATH"
fi