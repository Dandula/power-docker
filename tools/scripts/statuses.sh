#!/bin/bash

# shellcheck source=constants/colors.sh
. "${SCRIPT_DIR}/constants/colors.sh"

function set_color() {
  local COLOR="COLOR_$1"
  echo -en "${!COLOR}"
}

function show_status() {
  # shellcheck disable=SC2046
  echo "$(tput hpa $(tput cols))$(tput cub 6)[$1]"
}

function status_ok() {
  set_color 'SUCCESS'
  show_status ' OK '
  set_color 'NORMAL'
}

function status_fail() {
  set_color 'FAILURE'
  show_status 'FAIL'
  set_color 'NORMAL'
}

function message_colored() {
  set_color "$2"
  echo "$1"
  set_color 'NORMAL'
}

function message_success() {
  echo -n "$1" && status_ok
}

function message_failure() {
  echo -n "$1" && status_fail
}