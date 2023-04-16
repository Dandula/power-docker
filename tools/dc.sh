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

function enable_service() {
    # shellcheck disable=SC2155
    local SERVICE=$(to_lowercase "$1")
    local SERVICE_CONFIG_FILE="services/docker-compose.${SERVICE}.yml"

    CONFIG_FILES_STR="${CONFIG_FILES_STR} -f ${SERVICE_CONFIG_FILE}"

    in_array "$1" "${SERVICES_NEED_WWW[@]}"
    local SERVICE_NEED_WWW_STATUS=$?

    if [ $SERVICE_NEED_WWW_STATUS -eq 0 ]; then
      SERVICE_VOLUMES_CONFIG_FILE="services/docker-compose.${SERVICE}-volumes.yml"
      CONFIG_FILES_STR="${CONFIG_FILES_STR} -f ${SERVICE_VOLUMES_CONFIG_FILE}"
    fi
}

cd "$WORKSPACE_DIR" || exit

ENV_PATH="${WORKSPACE_DIR}/.env"

CONFIG_FILES_STR=" --env-file ${ENV_PATH} -f services/docker-compose.yml"

# shellcheck disable=SC2153
for SERVICE_NAME in ${SERVICES[*]}; do
  SERVICE_VARIABLE="SERVICE_$(to_snake_case "$(to_uppercase "$SERVICE_NAME")")"

  in_array "$SERVICE_NAME" "${DEFAULT_SERVICES[@]}"
  IS_DEFAULT_SERVICE_STATUS=$?

  if [ $IS_DEFAULT_SERVICE_STATUS -eq 0 ]; then
    SERVICE_STATE=$(parse_env "$SERVICE_VARIABLE" "${ENV_PATH}")
    case "$SERVICE_STATE" in
    0)
      ;;
    1|*)
      enable_service "$SERVICE_NAME"
      ;;
    esac
  else
    in_array "$SERVICE_NAME" "${CUSTOM_SERVICES[@]}"
    IS_CUSTOM_SERVICES_STATUS=$?

    if [ $IS_CUSTOM_SERVICES_STATUS -eq 0 ]; then
      enable_service "$SERVICE_NAME"
    fi
  fi
done

PHP_SERVICE_STATE=$(parse_env "SERVICE_PHP" "${ENV_PATH}")
BLACKFIRE_SERVICE_STATE=$(parse_env "SERVICE_BLACKFIRE" "${ENV_PATH}")

if [[ "$PHP_SERVICE_STATE" -ne 0 && "$BLACKFIRE_SERVICE_STATE" -ne 0 ]]; then
  PHP_BLACKFIRE_CONFIG_FILE="services/docker-compose.php-blackfire.yml"
  CONFIG_FILES_STR="${CONFIG_FILES_STR} -f ${PHP_BLACKFIRE_CONFIG_FILE}"
fi

DC_CMD="docker compose ${CONFIG_FILES_STR}"

"${SCRIPT_DIR}/mount_www.sh"

${DC_CMD} "$@"