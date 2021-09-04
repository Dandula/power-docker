#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"

DC="${SCRIPT_DIR}/dc.sh"

# shellcheck source=scripts/detect_wsl.sh
. "${SCRIPT_DIR}/scripts/detect_wsl.sh"
# shellcheck source=scripts/statuses.sh
. "${SCRIPT_DIR}/scripts/statuses.sh"

if [ -z "$1" ]; then
  CERT_FILENAME="id_ed25519"
else
  CERT_FILENAME="$1"
fi

read -er -p "Enter SSH certificate filename: " -i "$CERT_FILENAME" CERT_FILENAME

if [ -n "$2" ]; then
  COMMENT_EMAIL="$2"
  read -er -p "Enter email for comment: " -i "$COMMENT_EMAIL" COMMENT_EMAIL
else
  read -er -p "Enter email for comment: " COMMENT_EMAIL
fi

HOME_DIR="/home/docker"
MNT_CERTS_DIR="${HOME_DIR}/certs"

# shellcheck disable=SC2015
cd "$WORKSPACE_DIR" \
  && ${DC} run --rm php ssh-keygen -t ed25519 -C "${COMMENT_EMAIL}" -f "${MNT_CERTS_DIR}/${CERT_FILENAME}" -N "" \
  && message_success "SSH certificate is generated ($CERT_FILENAME and $CERT_FILENAME.pub)" \
  || message_failure "Error when generating SSH certificate"