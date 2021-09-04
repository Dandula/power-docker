#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"
ENV_PATH="${WORKSPACE_DIR}/.env"
HOSTS_DIR="${WORKSPACE_DIR}/hosts"

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
CONFIG_PATH="${HOSTS_DIR}/${CONFIG_FILE}"

LOGS_DIR="${WORKSPACE_DIR}/logs/nginx/${CONFIG_NAME}"
CERTS_DIR="${WORKSPACE_DIR}/data/certs"

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

if [[ "$(is_wsl)" -eq 0 && "${IS_HOST_CONFIG_CREATED}" -eq 1 ]]; then
  for SERVICE_NAME in ${SERVICES_NEED_WWW[*]}; do
    SERVICE_VARIABLE="SERVICE_$(to_snake_case "$(to_uppercase "$SERVICE_NAME")")"
    SERVICE=$(to_lowercase "$SERVICE_NAME")

    SERVICE_STATE=$(parse_env "$SERVICE_VARIABLE" "${ENV_PATH}")
    case "$SERVICE_STATE" in
    0)
      ;;
    1|*)
      ${DC} stop "${SERVICE}"
      ;;
    esac
  done
fi

if [[ -f "${CONFIG_PATH}" || -d "$LOGS_DIR" ]]; then
  if [ -f "${CONFIG_PATH}" ]; then
    rm "${CONFIG_PATH}" \
      && message_success "Host configuration removed $CONFIG_PATH"
  else
    message_failure "Host configuration $CONFIG_PATH not exists"
  fi

  if [ -d "$LOGS_DIR" ]; then
    sudo rm -r "$LOGS_DIR" \
      && message_success "Logs directory removed $LOGS_DIR"
  else
    message_failure "Logs directory $LOGS_DIR not exists"
  fi
else
  message_failure "Host configuration $CONFIG_PATH not exists"
  message_failure "Logs directory $LOGS_DIR not exists"
fi

HOSTS_MAP_PATH="${WORKSPACE_DIR}/hosts.map"

if grep -q "${DOMAIN}" "${HOSTS_MAP_PATH}"; then
  HOSTS_MAP_RECORD_REGEX="^${DOMAIN//./\\.}\:"
  sed -i "/${HOSTS_MAP_RECORD_REGEX}/d" "${HOSTS_MAP_PATH}" \
    && "${SCRIPT_DIR}/mount_www.sh" \
    && message_success "Domain $DOMAIN deleted from the file $HOSTS_MAP_PATH"
else
  message_failure "Domain $DOMAIN is missing in the file $HOSTS_MAP_PATH"
fi

if [[ "$(is_wsl)" -eq 0 && "${IS_HOST_CONFIG_CREATED}" -eq 1 ]]; then
  for SERVICE_NAME in ${SERVICES_NEED_WWW[*]}; do
    SERVICE_VARIABLE="SERVICE_$(to_snake_case "$(to_uppercase "$SERVICE_NAME")")"
    SERVICE=$(to_lowercase "$SERVICE_NAME")

    SERVICE_STATE=$(parse_env "$SERVICE_VARIABLE" "${ENV_PATH}")
    case "$SERVICE_STATE" in
    0)
      ;;
    1|*)
      ${DC} start "${SERVICE}"
      ;;
    esac
  done
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