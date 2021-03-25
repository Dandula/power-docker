#!/bin/bash

function parse_env() {
  local ENV_VAR
  ENV_VAR=$(grep "^$1=" "$2" | xargs)
  IFS="=" read -ra ENV_VAR <<< "${ENV_VAR}"
  echo "${ENV_VAR[1]%$'\r'}"
}