#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"
SERVICES_DIR="${WORKSPACE_DIR}/services"
HOSTS_MAP_PATH="${WORKSPACE_DIR}/hosts.map"

# shellcheck source=scripts/str_process.sh
. "${SCRIPT_DIR}/scripts/str_process.sh"
# shellcheck source=constants/services.sh
. "${SCRIPT_DIR}/constants/services.sh"

MNT_WWW_DIRS="
      - ${WORKSPACE_DIR}/www/opcache-gui:/var/www/opcache-gui
      - ${WORKSPACE_DIR}/www/apcu:/var/www/apcu
      - ${WORKSPACE_DIR}/www/phpmemadmin:/var/www/phpmemadmin"
while IFS= read -r MAP_RECORD; do
  WWW_DIR="${MAP_RECORD##*:}"

  if [ -n "$MAP_RECORD" ]; then
    DOMAIN="${MAP_RECORD%%:*}"
    WWW_BASE_DIR="${DOMAIN%%.*}"
    MNT_WWW_DIRS="${MNT_WWW_DIRS}
      - ${WWW_DIR}:/var/www/${WWW_BASE_DIR}"
  fi
done < "${HOSTS_MAP_PATH}"

for SERVICE_NAME in ${SERVICES_NEED_WWW[*]}; do
  SERVICE=$(to_lowercase "$SERVICE_NAME")
  SERVICE_VOLUMES_CONFIG_PATH="${SERVICES_DIR}/docker-compose.${SERVICE}-volumes.yml"

  cat > "${SERVICE_VOLUMES_CONFIG_PATH}" <<-EOF
	version: "3.8"

	services:
	  ${SERVICE}:
	    volumes:${MNT_WWW_DIRS}
EOF
done