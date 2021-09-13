#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"

DC="${SCRIPT_DIR}/dc.sh"

case "$1" in
  init|setup|dc|composer|npm)
    SCRIPT="${SCRIPT_DIR}/$1.sh"
    shift
    ;;
  help|'')
    SCRIPT="${SCRIPT_DIR}/help.sh"
    shift
    ;;
  host:add)
    SCRIPT="${SCRIPT_DIR}/host_add.sh"
    shift
    ;;
  host:del)
    SCRIPT="${SCRIPT_DIR}/host_del.sh"
    shift
    ;;
  mount:www)
    SCRIPT="${SCRIPT_DIR}/mount_www.sh"
    shift
    ;;
  make:ssh)
    SCRIPT="${SCRIPT_DIR}/make_ssh_cert.sh"
    shift
    ;;
  make:ssl)
    SCRIPT="${SCRIPT_DIR}/make_ssl_cert.sh"
    shift
    ;;
  mysql:export)
    SCRIPT="${SCRIPT_DIR}/mysql_export.sh"
    shift
    ;;
  mysql:import)
    SCRIPT="${SCRIPT_DIR}/mysql_import.sh"
    shift
    ;;
  mongo:export)
    SCRIPT="${SCRIPT_DIR}/mongo_export.sh"
    shift
    ;;
  mongo:import)
    SCRIPT="${SCRIPT_DIR}/mongo_import.sh"
    shift
    ;;
  cron:example)
    SCRIPT="${SCRIPT_DIR}/cron_example.sh"
    shift
    ;;
  python)
    SCRIPT="${SCRIPT_DIR}/python.sh"
    ARG="python"
    shift
    ;;
  pip)
    SCRIPT="${SCRIPT_DIR}/python.sh"
    ARG="pip"
    shift
    ;;
  poetry)
    SCRIPT="${SCRIPT_DIR}/python.sh"
    ARG="poetry"
    shift
    ;;
  *)
    SCRIPT="${DC}"
    ;;
esac

if [ -n "$ARG" ]; then
  "${SCRIPT}" "$ARG" $@
else
  "${SCRIPT}" $@
fi