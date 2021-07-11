#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"
HOSTS_DIR="${WORKSPACE_DIR}/hosts"

DC="${SCRIPT_DIR}/dc.sh"

# shellcheck source=scripts/statuses.sh
. "${SCRIPT_DIR}/scripts/statuses.sh"
# shellcheck source=scripts/detect_wsl.sh
. "${SCRIPT_DIR}/scripts/detect_wsl.sh"

if [ -z "$1" ]; then
  read -r -p "Enter host name: " DOMAIN
else
  read -er -p "Enter host name: " -i "$1" DOMAIN
fi

DOMAIN_LAST="${DOMAIN%%.*}"
CONFIG_NAME="${DOMAIN//./-}"
CONFIG_FILE="${CONFIG_NAME}.conf"
CONFIG_PATH="${HOSTS_DIR}/${CONFIG_FILE}"

WWW_DIR="${WORKSPACE_DIR}/www/${DOMAIN_LAST}"
LOGS_DIR="${WORKSPACE_DIR}/logs/nginx/${CONFIG_NAME}"
CERTS_DIR="${WORKSPACE_DIR}/data/certs"

CERT_PEM="${DOMAIN}-cert.pem"
CERT_KEY="${DOMAIN}-cert.key"

IS_HOST_CONFIG_CREATED=0
NEED_CERT=0

if [ ! -f "${CONFIG_PATH}" ]; then
  read -r -d '' HTTP_CONFIG <<-EOM
		    listen 80;
EOM

  read -r -d '' HTTPS_CONFIG <<-EOM
		    listen 443 ssl;
EOM

  read -r -d '' HTTP_HTTPS_CONFIG <<-EOM
		    ${HTTP_CONFIG}
		    ${HTTPS_CONFIG}
EOM

  read -r -d '' CERTS_CONFIG <<-EOM
		    ssl_certificate /var/certs/${CERT_PEM};
		    ssl_certificate_key /var/certs/${CERT_KEY};
EOM

  read -r -p "Choose scheme (1 - HTTP, 2 - HTTPS, 3 - HTTP + HTTPS) [1]: " SCHEME
  SCHEME=${SCHEME:-1}

  read -r -p "Are you adding a Laravel host? (Y/N) [N]: " IS_LARAVEL
  IS_LARAVEL=${IS_LARAVEL:-N}

  case "$IS_LARAVEL" in
  Y|y)
    read -r -d '' REDIRECT_TO_HTTPS <<-EOM
			server {
			    listen 80;
			    server_name ${DOMAIN};
			    return 301 https://${DOMAIN}\$request_uri;
			}
EOM
    IS_LARAVEL=1
    ;;
  N|n|*)
    IS_LARAVEL=0
    ;;
  esac

  case "$SCHEME" in
  2)
    PORT_CONFIG=$HTTPS_CONFIG
    REDIRECT_TO_HTTPS=''
    NEED_CERT=1
    ;;
  3)
    if [ "${IS_LARAVEL}" -eq 0 ]; then
      PORT_CONFIG=$HTTP_HTTPS_CONFIG
    else
      PORT_CONFIG=$HTTPS_CONFIG
    fi
    NEED_CERT=1
    ;;
  1|*)
    PORT_CONFIG=$HTTP_CONFIG
    REDIRECT_TO_HTTPS=''
    CERTS_CONFIG=''
    ;;
  esac

  if [ "$(is_wsl)" -eq 1 ]; then
    read -r -d '' CERTS_CONFIG <<-EOM
			#    ssl_certificate /var/certs/${CERT_PEM};
			#    ssl_certificate_key /var/certs/${CERT_KEY};
EOM
    NEED_CERT=0
  fi

  echo

  if [ "${IS_LARAVEL}" -eq 0 ]; then
    { cat > "${CONFIG_PATH}" <<-EOF
			server {
			    ${PORT_CONFIG}
			    index index.php;
			    server_name ${DOMAIN};
			    error_log /var/log/nginx/${CONFIG_NAME}/error.log;
			    access_log /var/log/nginx/${CONFIG_NAME}/access.log;
			    root /var/www/${DOMAIN_LAST};
			    ${CERTS_CONFIG}
			    location ~ \.php$ {
			        try_files \$uri =404;
			        fastcgi_split_path_info ^(.+\.php)(/.+)$;
			        fastcgi_pass php:9000;
			        fastcgi_index index.php;
			        include fastcgi_params;
			        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
			        fastcgi_param PATH_INFO \$fastcgi_path_info;
			    }
			}
EOF
    } && message_success "Host configuration created $CONFIG_PATH" \
      && IS_HOST_CONFIG_CREATED=1
  else
    { cat > "${CONFIG_PATH}" <<-EOF
			server {
			    ${PORT_CONFIG}
			    server_name ${DOMAIN};
			    root /var/www/${DOMAIN_LAST}/public;

			    error_log /var/log/nginx/${CONFIG_NAME}/error.log;
			    access_log /var/log/nginx/${CONFIG_NAME}/access.log;
			    ${CERTS_CONFIG}

			    add_header X-Frame-Options "SAMEORIGIN";
			    add_header X-XSS-Protection "1; mode=block";
			    add_header X-Content-Type-Options "nosniff";

			    index index.php;

			    charset utf-8;

			    location / {
			        try_files \$uri \$uri/ /index.php?\$query_string;
			    }

			    location = /favicon.ico { access_log off; log_not_found off; }
			    location = /robots.txt  { access_log off; log_not_found off; }

			    error_page 404 /index.php;

			    location ~ \.php$ {
			        fastcgi_pass php:9000;
			        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
			        include fastcgi_params;
			    }

			    location ~ /\.(?!well-known).* {
			        deny all;
			    }
			}

			${REDIRECT_TO_HTTPS}
EOF
    } && message_success "Host configuration created $CONFIG_PATH" \
      && IS_HOST_CONFIG_CREATED=1
  fi
else
  echo
  message_failure "Host configuration $CONFIG_PATH already exists"
fi

if [ ! -d "$WWW_DIR" ]; then
  mkdir -p "$WWW_DIR" &&
    message_success "Host directory created $WWW_DIR"
else
  message_failure "Host directory $WWW_DIR already exists"
fi

if [ ! -d "$LOGS_DIR" ]; then
  sudo mkdir -p "$LOGS_DIR" &&
    message_success "Logs directory created $LOGS_DIR"
else
  message_failure "Logs directory $LOGS_DIR already exists"
fi

if [ "$(is_wsl)" -eq 1 ]; then
  HOSTS_PATH="/mnt/c/Windows/System32/drivers/etc/hosts"
else
  HOSTS_PATH="/etc/hosts"
fi

HOST_RECORD="127.0.0.1	${DOMAIN}"
HOST_RECORD_REGEX="127\.0\.0\.1\s*${DOMAIN}$"

if ! grep -q "${HOST_RECORD_REGEX}" "${HOSTS_PATH}"; then
  sudo sh -c "echo '\n${HOST_RECORD}' >> ${HOSTS_PATH}" &&
    message_success "Domain ${DOMAIN} is defined in the file ${HOSTS_PATH}"
else
  message_failure "Domain ${DOMAIN} is already defined in the file ${HOSTS_PATH}"
fi

if [ "${NEED_CERT}" -eq 1 ]; then
  # shellcheck disable=SC2015
  bash -c "${SCRIPT_DIR}/make_ssl_cert.sh ${DOMAIN} > /dev/null 2>&1" \
    && message_success "SSL certificate is generated (${CERT_PEM} and ${CERT_KEY}) and put to the directory ${CERTS_DIR}" \
    || message_failure "Error when generating SSL certificate"
fi

if [[ "$(is_wsl)" -eq 0 && "${IS_HOST_CONFIG_CREATED}" -eq 1 ]]; then
  ${DC} restart nginx
fi