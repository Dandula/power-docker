#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"

# shellcheck source=constants/services.sh
. "${SCRIPT_DIR}/constants/services.sh"
# shellcheck source=scripts/parse_env.sh
. "${SCRIPT_DIR}/scripts/parse_env.sh"
# shellcheck source=scripts/str_process.sh"
. "${SCRIPT_DIR}/scripts/str_process.sh"
# shellcheck source=scripts/arr_process.sh"
. "${SCRIPT_DIR}/scripts/arr_process.sh"

cd "$WORKSPACE_DIR" || exit

ENV_PATH="${WORKSPACE_DIR}/.env"

CONFIG_FILES_STR=" -f services/docker-compose.yml"

# shellcheck disable=SC2153
for SERVICE_NAME in ${SERVICES[*]}; do
  SERVICE_VARIABLE="SERVICE_$(to_snake_case "$(to_uppercase "$SERVICE_NAME")")"
  SERVICE=$(to_lowercase "$SERVICE_NAME")

  SERVICE_STATE=$(parse_env "$SERVICE_VARIABLE" "${ENV_PATH}")
  case "$SERVICE_STATE" in
  0)
    ;;
  1|*)
    SERVICE_CONFIG_FILE="services/docker-compose.${SERVICE}.yml"
    CONFIG_FILES_STR="${CONFIG_FILES_STR} -f ${SERVICE_CONFIG_FILE}"

    in_array "${SERVICE_NAME}" "${SERVICES_NEED_WWW[@]}"
    SERVICE_NEED_WWW_STATUS=$?

    if [ $SERVICE_NEED_WWW_STATUS -eq 0 ]; then
      SERVICE_VOLUMES_CONFIG_FILE="services/docker-compose.${SERVICE}-volumes.yml"
      CONFIG_FILES_STR="${CONFIG_FILES_STR} -f ${SERVICE_VOLUMES_CONFIG_FILE}"
    fi
    ;;
  esac
done

DC_CMD="docker-compose ${CONFIG_FILES_STR}"

${DC_CMD} "$@"