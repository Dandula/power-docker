#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"
NGROK_IMAGE_DIR="${WORKSPACE_DIR}/images/ngrok"
NGROK_LOGS_DIR="${WORKSPACE_DIR}/logs/ngrok"
ENV_PATH="${WORKSPACE_DIR}/.env"

# shellcheck source=../parse_env.sh
. "${SCRIPT_DIR}/scripts/parse_env.sh"

NGROK_AUTHTOKEN=$(parse_env "NGROK_AUTHTOKEN" "${ENV_PATH}")
NGROK_CONFIG_PATH="/etc/ngrok.yml"

if [ -z "$1" ]; then
  read -r -p "Please set local URL for publishing: " URL
else
  read -er -p "Please set local URL for publishing: " -i "$1" URL
fi

if [ -z "$URL" ]; then
  URL=localhost
fi

IFS=':' read -ra PATHINFO <<< "$URL"
if [ ${#PATHINFO[@]} -eq 2 ]; then
  HOST="${PATHINFO[0]}"
  PORT="${PATHINFO[1]}"
else
  HOST="${PATHINFO[0]}"
  PORT="80"
fi

REFERENCE="${HOST}:${PORT}"

CMD="http ${REFERENCE}"
if [ "${HOST}" != "localhost" ]; then
  CMD="${CMD} -host-header=${REFERENCE}"
fi

docker run --rm -it \
  -e "NGROK_AUTHTOKEN=${NGROK_AUTHTOKEN}" \
  -e "NGROK_CONFIG=${NGROK_CONFIG_PATH}" \
  -v "${NGROK_IMAGE_DIR}/ngrok.yml:${NGROK_CONFIG_PATH}" \
  -v "${NGROK_LOGS_DIR}:/var/log/ngrok" \
  --network="host" \
  ngrok/ngrok ${CMD}