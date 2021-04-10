#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"
NPM_DIR="${WORKSPACE_DIR}/data/cache/.npm"

docker run --rm -it \
  -w "/usr/src/app" \
  -v "${PWD}:/usr/src/app" \
  -v "${NPM_DIR}:/home/node/.npm" \
  -u "${UID}:$(id -g)" \
  node npm "$@"