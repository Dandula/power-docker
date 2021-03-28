#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"
CERTS_DIR="${WORKSPACE_DIR}/data/certs"

DOMAIN="$1"
CERT_PEM="${DOMAIN}-cert.pem"
CERT_KEY="${DOMAIN}-cert.key"

cd "$CERTS_DIR" \
  && mkcert -cert-file "${CERT_PEM}" -key-file "${CERT_KEY}" "${DOMAIN}" "*.${DOMAIN}"