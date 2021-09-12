#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"
PIP_DIR="${WORKSPACE_DIR}/data/cache/.pip"
POETRY_DIR="${WORKSPACE_DIR}/data/cache/.pypoetry"

# shellcheck source=scripts/parse_env.sh
. "${SCRIPT_DIR}/scripts/parse_env.sh"

ENV_PATH="${WORKSPACE_DIR}/.env"

TIMEZONE=$(parse_env "TIMEZONE" "${ENV_PATH}")

docker run --rm -it \
  -e "TZ=${TIMEZONE}" \
  -w "/usr/src/app" \
  -v "${PWD}:/usr/src/app" \
  -v "${PIP_DIR}:/home/docker/.cache/pip" \
  -v "${POETRY_DIR}:/home/docker/.cache/pypoetry" \
  ws-python "$@"