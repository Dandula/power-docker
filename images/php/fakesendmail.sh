#!/bin/sh

MAIL_DIR="/var/mail/sendmail"
TIME=$(date +"%Y_%m_%d_%H%M%S")
MAIL_FILEPATH="${MAIL_DIR}/mail_${TIME}.eml"

while read -r LINE; do
  echo "$LINE" >> "$MAIL_FILEPATH"
done

chmod 666 "$MAIL_FILEPATH"

/bin/true