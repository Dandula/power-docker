#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"

# shellcheck source=scripts/parse_env.sh
. "${SCRIPT_DIR}/scripts/parse_env.sh"
# shellcheck source=scripts/parse_env.sh
. "${SCRIPT_DIR}/scripts/str_process.sh"
# shellcheck source=constants/services.sh
. "${SCRIPT_DIR}/constants/services.sh"

cd "$WORKSPACE_DIR" || exit

ENV_PATH="${WORKSPACE_DIR}/.env"

CONFIG_FILES_STR=" -f services/docker-compose.yml"

for SERVICE_NAME in ${SERVICES[*]}; do
  SERVICE_VARIABLE="SERVICE_$(to_snake_case "$(to_uppercase "$SERVICE_NAME")")"
  SERVICE_CONFIG_FILE="services/docker-compose.$(to_lowercase "$SERVICE_NAME").yml"

  SERVICE_STATE=$(parse_env "$SERVICE_VARIABLE" "${ENV_PATH}")
  case "$SERVICE_STATE" in
  0)
    ;;
  1|*)
    CONFIG_FILES_STR="${CONFIG_FILES_STR} -f ${SERVICE_CONFIG_FILE}"
    ;;
  esac
done

DC_CMD="docker-compose ${CONFIG_FILES_STR}"

${DC_CMD} "$@"