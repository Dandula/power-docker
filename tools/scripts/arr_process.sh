#!/bin/bash

function in_array() {
  local NEEDLE="$1"
  local ITEM
  shift
  for ITEM; do
    [[ "${ITEM}" == "$NEEDLE" ]] && return 0
  done
  return 1
}