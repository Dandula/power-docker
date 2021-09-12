#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"
PYTHON_IMAGE_DIR="${WORKSPACE_DIR}/images/python"

# shellcheck source=scripts/parse_env.sh
. "${SCRIPT_DIR}/scripts/parse_env.sh"
# shellcheck source=scripts/statuses.sh
. "${SCRIPT_DIR}/scripts/statuses.sh"

ENV_PATH="${WORKSPACE_DIR}/.env"

USER_ID=$(parse_env "USER_ID" "${ENV_PATH}")
GROUP_ID=$(parse_env "GROUP_ID" "${ENV_PATH}")
PYTHON_VER=$(parse_env "PYTHON_VER" "${ENV_PATH}")

PYTHON_VER=$(parse_env "PYTHON_VER" "${ENV_PATH}")
read -er -p "Enter Python version [3.9]: " -i "$PYTHON_VER" PYTHON_VER
if [ -z "$PYTHON_VER" ]; then
  PYTHON_VER="3.9"
fi
sed -i "s%^PYTHON_VER=.*%PYTHON_VER=$PYTHON_VER%" "$ENV_PATH"

docker build \
    --build-arg USER_ID="${USER_ID}" \
    --build-arg GROUP_ID="${GROUP_ID}" \
    --build-arg PYTHON_VER="${PYTHON_VER}" \
    -t pd-python "${PYTHON_IMAGE_DIR}" \
  && message_success "Python are configured" \
  || message_failure "Python configuration error"