#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"

# shellcheck source=scripts/statuses.sh
. "${SCRIPT_DIR}/scripts/statuses.sh"

function yoda_command() {
  COMMAND=$1
  DESCRIPTION=$2
  INDENT=0
  WIDTH=20

  if [ -n $3 ]; then
    INDENT=$((2 * $3))
    WIDTH=$(($WIDTH - $INDENT))
  fi

  set_color "SUCCESS"
  printf "%${INDENT}s%-${WIDTH}s" "" "$COMMAND"
  set_color "NORMAL"

  if [ -n "${DESCRIPTION}" ]; then
    printf " - $DESCRIPTION"
  fi

  printf "\n"
}

read -r -d '' YODA < "${WORKSPACE_DIR}/assets/yoda.txt"
message_colored "$YODA" "SUCCESS"
set_color "NORMAL"

echo "PowerDocker Commands List:"
yoda_command "init" "workspace initialization" 0
yoda_command "[--clean-install]" "clean workspace initialization" 1
yoda_command "help" "this help" 0
yoda_command "setup" "configure a set of services" 0
yoda_command "dc <command>" "'docker-compose <command>' redirect" 0
yoda_command "composer <command>" "'composer <command>' redirect" 0
yoda_command "npm <command>" "'npm <command>' redirect" 0
yoda_command "host:" "" 0
yoda_command "add <domain> <dir>" "add a new host" 1
yoda_command "del <domain>" "delete the host" 1
yoda_command "pub <domain>" "give access to the host from the Internet via ngrok" 1
yoda_command "mount:" "" 0
yoda_command "www" "mount WWW directories defined at hosts.map file" 1
yoda_command "make:" "" 0
yoda_command "ssh <file> <email>" "make SSH certificate for SSH agent" 1
yoda_command "ssl" "make SSL certificate for a domain" 1
yoda_command "mysql:" "" 0
yoda_command "export <db>" "export MySQL database dump" 1
yoda_command "import <dump>" "import MySQL database dump" 1
yoda_command "mongo:" "" 0
yoda_command "export <db>" "export Mongo database dump" 1
yoda_command "import <dump>" "import Mongo database dump" 1
yoda_command "cron:" "" 0
yoda_command "example" "add CRON job example" 1
yoda_command "python <command>" "run Python command" 0
yoda_command "pip <command>" "run pip command" 0
yoda_command "poetry <command>" "run Poetry command" 0
yoda_command "aws <command>" "LocalStack AWS-CLI command" 0