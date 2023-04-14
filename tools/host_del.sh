#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"
ENV_PATH="${WORKSPACE_DIR}/.env"
HOSTS_DIR="${WORKSPACE_DIR}/hosts"
HOSTS_APACHE_DIR="${HOSTS_DIR}/apache"
HOSTS_NGINX_DIR="${HOSTS_DIR}/nginx"

DC="${SCRIPT_DIR}/dc.sh"

# shellcheck source=constants/services.sh
. "${SCRIPT_DIR}/constants/services.sh"
# shellcheck source=scripts/parse_env.sh
. "${SCRIPT_DIR}/scripts/parse_env.sh"
# shellcheck source=scripts/detect_wsl.sh
. "${SCRIPT_DIR}/scripts/detect_wsl.sh"
# shellcheck source=scripts/statuses.sh
. "${SCRIPT_DIR}/scripts/statuses.sh"
# shellcheck source=scripts/str_process.sh
. "${SCRIPT_DIR}/scripts/str_process.sh"

if [ -z "$1" ]; then
  read -r -p "Enter host name: " DOMAIN
else
  read -er -p "Enter host name: " -i "$1" DOMAIN
fi

CONFIG_NAME="${DOMAIN//./-}"
CONFIG_FILE="${CONFIG_NAME}.conf"
CONFIG_APACHE_PATH="${HOSTS_APACHE_DIR}/${CONFIG_FILE}"
CONFIG_NGINX_PATH="${HOSTS_NGINX_DIR}/${CONFIG_FILE}"

LOGS_DIR="${WORKSPACE_DIR}/logs"
LOGS_APACHE_DIR="${LOGS_DIR}/apache/${CONFIG_NAME}"
LOGS_NGINX_DIR="${LOGS_DIR}/nginx/${CONFIG_NAME}"
CERTS_DIR="${WORKSPACE_DIR}/data/certs/hosts"

CERT_PEM="${DOMAIN}-cert.pem"
CERT_KEY="${DOMAIN}-cert.key"
CERT_PEM_PATH="${CERTS_DIR}/${CERT_PEM}"
CERT_KEY_PATH="${CERTS_DIR}/${CERT_KEY}"

read -r -p "Are you sure you want to delete the host $DOMAIN? (Y/N) [N]: " IS_SURE
IS_SURE=${IS_SURE:-N}

echo

case "$IS_SURE" in
Y|y)
  echo "Host deletion confirmed..."
  ;;
N|n|*)
  echo "Host deletion not confirmed"
  exit
  ;;
esac

if [ "$(is_wsl)" -eq 0 ]; then
  RELOADING_SERVICES=""

  for SERVICE_NAME in ${SERVICES_NEED_WWW[*]}; do
    SERVICE_VARIABLE="SERVICE_$(to_snake_case "$(to_uppercase "$SERVICE_NAME")")"
    SERVICE=$(to_lowercase "$SERVICE_NAME")

    SERVICE_STATE=$(parse_env "$SERVICE_VARIABLE" "${ENV_PATH}")
    case "$SERVICE_STATE" in
    0)
      ;;
    1|*)
      RELOADING_SERVICES="${RELOADING_SERVICES} ${SERVICE}"
      ;;
    esac
  done

  if [ -n "$RELOADING_SERVICES" ]; then
    ${DC} rm -fs "${SERVICE}"
  fi
fi

if [[ -f "${CONFIG_APACHE_PATH}" || -d "$LOGS_APACHE_DIR" ]]; then
  if [ -f "${CONFIG_APACHE_PATH}" ]; then
    rm "${CONFIG_APACHE_PATH}" \
      && message_success "Apache host configuration removed $CONFIG_APACHE_PATH"
  else
    message_failure "Apache host configuration $CONFIG_APACHE_PATH not exists"
  fi

  if [ -d "$LOGS_APACHE_DIR" ]; then
    sudo rm -r "${LOGS_APACHE_DIR}" \
      && message_success "Apache logs directory removed $LOGS_APACHE_DIR"
  else
    message_failure "Apache logs directory $LOGS_APACHE_DIR not exists"
  fi
else
  message_failure "Apache host configuration $CONFIG_APACHE_PATH not exists"
  message_failure "Apache logs directory $LOGS_APACHE_DIR not exists"
fi

if [[ -f "${CONFIG_NGINX_PATH}" || -d "$LOGS_NGINX_DIR" ]]; then
  if [ -f "$CONFIG_NGINX_PATH" ]; then
    rm "${CONFIG_NGINX_PATH}" \
      && message_success "nginx host configuration removed $CONFIG_NGINX_PATH"
  else
    message_failure "nginx host configuration $CONFIG_NGINX_PATH not exists"
  fi

  if [ -d "${LOGS_NGINX_DIR}" ]; then
    sudo rm -r "${LOGS_NGINX_DIR}" \
      && message_success "nginx logs directory removed $LOGS_NGINX_DIR"
  else
    message_failure "nginx logs directory $LOGS_NGINX_DIR not exists"
  fi
else
  message_failure "nginx host configuration $CONFIG_NGINX_PATH not exists"
  message_failure "nginx logs directory $LOGS_NGINX_DIR not exists"
fi

HOSTS_MAP_PATH="${WORKSPACE_DIR}/hosts.map"

touch ${HOSTS_MAP_PATH}

if grep -q "${DOMAIN}" "${HOSTS_MAP_PATH}"; then
  HOSTS_MAP_RECORD_REGEX="^${DOMAIN//./\\.}\:"
  sed -i "/${HOSTS_MAP_RECORD_REGEX}/d" "${HOSTS_MAP_PATH}" \
    && "${SCRIPT_DIR}/mount_www.sh" \
    && message_success "Domain $DOMAIN deleted from the file $HOSTS_MAP_PATH"
else
  message_failure "Domain $DOMAIN is missing in the file $HOSTS_MAP_PATH"
fi

NODE_PORTS_MAP_PATH="${WORKSPACE_DIR}/node-ports.map"

touch ${NODE_PORTS_MAP_PATH}

if grep -q "${DOMAIN}" "${NODE_PORTS_MAP_PATH}"; then
  NODE_PORTS_MAP_RECORD_REGEX="^${DOMAIN//./\\.}\:"
  sed -i "/${NODE_PORTS_MAP_RECORD_REGEX}/d" "${NODE_PORTS_MAP_PATH}" \
    && message_success "Domain $DOMAIN deleted from the file $NODE_PORTS_MAP_PATH"
else
  message_failure "Domain $DOMAIN is missing in the file $NODE_PORTS_MAP_PATH"
fi

if [ -f "$CERT_PEM_PATH" ]; then
  rm "$CERT_PEM_PATH" \
    && message_success "SSL certificate public key removed $CERT_PEM_PATH"
else
  message_failure "SSL certificate public key $CERT_PEM_PATH not exists"
fi

if [ -f "$CERT_KEY_PATH" ]; then
  rm "$CERT_KEY_PATH" \
    && message_success "SSL certificate private key removed $CERT_KEY_PATH"
else
  message_failure "SSL certificate private key $CERT_KEY_PATH not exists"
fi

if [ "$(is_wsl)" -eq 1 ]; then
  HOSTS_PATH="/mnt/c/Windows/System32/drivers/etc/hosts"
else
  HOSTS_PATH="/etc/hosts"
fi

HOST_RECORD_REGEX="127\.0\.0\.1\s*${DOMAIN}"

if grep -q "${HOST_RECORD_REGEX}" "${HOSTS_PATH}"; then
  sudo sed -i "/${HOST_RECORD_REGEX}/d" "${HOSTS_PATH}" \
    && message_success "Domain $DOMAIN deleted from the file $HOSTS_PATH"
else
  message_failure "Domain $DOMAIN is missing in the file $HOSTS_PATH"
fi

if [ "$(is_wsl)" -eq 0 ]; then
  RELOADING_SERVICES=""

  for SERVICE_NAME in ${SERVICES_NEED_WWW[*]}; do
    SERVICE_VARIABLE="SERVICE_$(to_snake_case "$(to_uppercase "$SERVICE_NAME")")"
    SERVICE=$(to_lowercase "$SERVICE_NAME")

    SERVICE_STATE=$(parse_env "$SERVICE_VARIABLE" "${ENV_PATH}")
    case "$SERVICE_STATE" in
    0)
      ;;
    1|*)
      RELOADING_SERVICES="${RELOADING_SERVICES} ${SERVICE}"
      ${DC} start "${SERVICE}"
      ;;
    esac
  done
fi

if [[ "$(is_wsl)" -eq 0 && "${IS_HOST_CONFIG_CREATED}" -eq 1 && -n "$RELOADING_SERVICES" ]]; then
  ${DC} up -d "${SERVICE}"
fi