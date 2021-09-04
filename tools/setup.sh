#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"

DC="${SCRIPT_DIR}/dc.sh"

# shellcheck source=constants/services.sh
. "${SCRIPT_DIR}/constants/services.sh"
# shellcheck source=scripts/parse_env.sh
. "${SCRIPT_DIR}/scripts/parse_env.sh"
# shellcheck source=scripts/str_process.sh
. "${SCRIPT_DIR}/scripts/str_process.sh"

${DC} down

ENV_PATH="${WORKSPACE_DIR}/.env"

for SERVICE_NAME in ${SERVICES[*]}; do
  SERVICE_VARIABLE="SERVICE_$(to_snake_case "$(to_uppercase "$SERVICE_NAME")")"

  SERVICE_STATE=$(parse_env "$SERVICE_VARIABLE" "${ENV_PATH}")
  case "$SERVICE_STATE" in
  0)
    SERVICE_STATE="N"
    ;;
  1|*)
    SERVICE_STATE="Y"
    ;;
  esac

  read -er -p "Enable $SERVICE_NAME service (Y/N) [Y]: " -i "$SERVICE_STATE" SERVICE_STATE
  case "$SERVICE_STATE" in
  Y|y)
    SERVICE_STATE=1
    ;;
  N|n|*)
    SERVICE_STATE=0
    ;;
  esac
  sed -i "s%^${SERVICE_VARIABLE}=.*%${SERVICE_VARIABLE}=${SERVICE_STATE}%" "$ENV_PATH"
done