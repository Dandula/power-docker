#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"
PYTHON_IMAGE_DIR="${WORKSPACE_DIR}/images/python"
PIP_DIR="${WORKSPACE_DIR}/data/cache/.pip"
POETRY_DIR="${WORKSPACE_DIR}/data/cache/.pypoetry"

# shellcheck source=scripts/parse_env.sh
. "${SCRIPT_DIR}/scripts/parse_env.sh"

ENV_PATH="${WORKSPACE_DIR}/.env"

USER_ID=$(parse_env "USER_ID" "${ENV_PATH}")
GROUP_ID=$(parse_env "GROUP_ID" "${ENV_PATH}")
PYTHON_VER=$(parse_env "PYTHON_VER" "${ENV_PATH}")
TIMEZONE=$(parse_env "TIMEZONE" "${ENV_PATH}")

EXISTING_PYTHON_CONTAINER_ID=$(docker images -f reference=ws-python:${PYTHON_VER} --format "{{.ID}}")

if [ -z "$EXISTING_PYTHON_CONTAINER_ID" ]; then
  docker build \
      --build-arg USER_ID="${USER_ID}" \
      --build-arg GROUP_ID="${GROUP_ID}" \
      --build-arg PYTHON_VER="${PYTHON_VER}" \
      -t ws-python:${PYTHON_VER} "${PYTHON_IMAGE_DIR}"
fi

docker run --rm -it \
  -e "TZ=${TIMEZONE}" \
  -w "/usr/src/app" \
  -v "${PWD}:/usr/src/app" \
  -v "${PIP_DIR}:/home/docker/.cache/pip" \
  -v "${POETRY_DIR}:/home/docker/.cache/pypoetry" \
  ws-python:${PYTHON_VER} "$@"