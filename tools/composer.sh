#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"
COMPOSER_DIR="${WORKSPACE_DIR}/data/cache/.composer"

if [ -n "$SSH_AUTH_SOCK" ]; then
  docker run --rm -it \
    -v "${PWD}:/app" \
    -v "${COMPOSER_DIR}:/tmp" \
    -v $SSH_AUTH_SOCK:/ssh-auth.sock \
    -v /etc/passwd:/etc/passwd:ro \
    -v /etc/group:/etc/group:ro \
    -e SSH_AUTH_SOCK=/ssh-auth.sock \
    -u "${UID}:$(id -g)" \
    composer "$@" --ignore-platform-reqs
else
  docker run --rm -it \
    -v "${PWD}:/app" \
    -v "${COMPOSER_DIR}:/tmp" \
    -u "${UID}:$(id -g)" \
    composer "$@" --ignore-platform-reqs
fi