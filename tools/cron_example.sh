#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"
CRON_JOBS_DIR="${WORKSPACE_DIR}/data/cron"

DC="${SCRIPT_DIR}/dc.sh"

# shellcheck source=scripts/detect_wsl.sh
. "${SCRIPT_DIR}/scripts/detect_wsl.sh"
# shellcheck source=scripts/statuses.sh
. "${SCRIPT_DIR}/scripts/statuses.sh"

if [ -z "$1" ]; then
  EXAMPLE_FILENAME="example"
else
  EXAMPLE_FILENAME="$1"
fi

read -er -p "Enter example filename: " -i "$EXAMPLE_FILENAME" EXAMPLE_FILENAME

CRON_EXAMPLE_PATH="${CRON_JOBS_DIR}/${EXAMPLE_FILENAME}"

{ cat > "${CRON_EXAMPLE_PATH}" <<EOF
* * * * * docker echo "Hello world" >> /var/log/cron/cron.log 2>&1
EOF
    } && message_success "CRON job example created $CRON_EXAMPLE_PATH"

if [ "$(is_wsl)" -eq 0 ]; then
  ${DC} restart schedule
fi