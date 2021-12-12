#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"
NPM_DIR="${WORKSPACE_DIR}/data/cache/.npm"

# shellcheck source=scripts/parse_env.sh
. "${SCRIPT_DIR}/scripts/parse_env.sh"

ENV_PATH="${WORKSPACE_DIR}/.env"

NODE_VER=$(parse_env "NODE_VER" "${ENV_PATH}")

docker run --rm -it \
  -w "/usr/src/app" \
  -v "${PWD}:/usr/src/app" \
  -v "${NPM_DIR}:/home/node/.npm" \
  -u "${UID}:$(id -g)" \
  --network="host" \
  node:${NODE_VER} npm "$@"