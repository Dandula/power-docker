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

WEB_SERVER=$(parse_env "WEB_SERVER" "${ENV_PATH}")
case "$WEB_SERVER" in
disabled)
  WEB_SERVER=0
  ;;
nginx)
  WEB_SERVER=2
  ${DC} rm apache
  ;;
apache|*)
  WEB_SERVER=1
  ${DC} rm nginx
  ;;
esac

read -er -p "Choose current WEB server (0 - disabled, 1 - Apache, 2 - nginx) [1]: " -i "$WEB_SERVER" WEB_SERVER
WEB_SERVER=${WEB_SERVER:-1}

case "$WEB_SERVER" in
0)
  WEB_SERVER="default"
  APACHE_STATE=0
  NGINX_STATE=0
  ;;
2)
  WEB_SERVER="nginx"
  APACHE_STATE=0
  NGINX_STATE=1
  ;;
1|*)
  WEB_SERVER="apache"
  APACHE_STATE=1
  NGINX_STATE=0
  ;;
esac

sed -i "s%^WEB_SERVER=.*%WEB_SERVER=${WEB_SERVER}%" "$ENV_PATH"
sed -i "s%^SERVICE_APACHE=.*%SERVICE_APACHE=${APACHE_STATE}%" "$ENV_PATH"
sed -i "s%^SERVICE_NGINX=.*%SERVICE_NGINX=${NGINX_STATE}%" "$ENV_PATH"

for SERVICE_NAME in ${SERVICES[*]}; do
  case "$SERVICE_NAME" in
  Apache|nginx)
    ;;
  *)
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
    ;;
  esac
done