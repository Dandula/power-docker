#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"

DC="${SCRIPT_DIR}/dc.sh"

# shellcheck disable=SC2015
cd "$WORKSPACE_DIR" \
  && ${DC} exec localstack awslocal "$@"