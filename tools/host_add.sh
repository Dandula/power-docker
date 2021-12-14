#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"
ENV_PATH="${WORKSPACE_DIR}/.env"
HOSTS_DIR="${WORKSPACE_DIR}/hosts"
HOSTS_APACHE_DIR="${HOSTS_DIR}/apache"
HOSTS_NGINX_DIR="${HOSTS_DIR}/nginx"

DC="${SCRIPT_DIR}/dc.sh"

# shellcheck source=constants/services.sh
. "${SCRIPT_DIR}/constants/services.sh"
# shellcheck source=scripts/parse_env.sh
. "${SCRIPT_DIR}/scripts/parse_env.sh"
# shellcheck source=scripts/detect_wsl.sh
. "${SCRIPT_DIR}/scripts/detect_wsl.sh"
# shellcheck source=scripts/statuses.sh
. "${SCRIPT_DIR}/scripts/statuses.sh"
# shellcheck source=scripts/str_process.sh
. "${SCRIPT_DIR}/scripts/str_process.sh"

if [ -z "$1" ]; then
  read -r -p "Enter host name: " DOMAIN
else
  read -er -p "Enter host name: " -i "$1" DOMAIN
fi

GENERAL_WWW_DIR="${WORKSPACE_DIR}/www"
WWW_BASE_DIR="${DOMAIN%%.*}"
WWW_DIR="${GENERAL_WWW_DIR}/${WWW_BASE_DIR}"

IS_WWW_DIR_DEFINED=0

until [ "${IS_WWW_DIR_DEFINED}" -eq 1 ]; do
  if [ -z "$2" ]; then
    read -r -p "Enter full path to host directory (leave blank to be placed in the directory $WWW_DIR): " REAL_WWW_DIR
  else
    read -er -p "Enter full path to host directory (leave blank to be placed in the directory $WWW_DIR): " -i "$2" REAL_WWW_DIR
  fi

  if [ -n "$REAL_WWW_DIR" ]; then
    if [[ $REAL_WWW_DIR != /* ]]; then
      message_colored "You must enter full path!" "FAILURE" \
        && continue
    fi

    if [ ! -d "$REAL_WWW_DIR" ]; then
      message_colored "You must enter existing path!" "FAILURE" \
        && continue
    fi

    WWW_BASE_DIR="$(basename "$REAL_WWW_DIR")"
    WWW_DIR="${REAL_WWW_DIR}"
  else
    if [ ! -d "$WWW_DIR" ]; then
      mkdir -p "$WWW_DIR" &&
        message_success "Host directory created $WWW_DIR"
    else
      message_failure "Host directory $WWW_DIR already exists"
    fi
  fi

  HOSTS_MAP_PATH="${WORKSPACE_DIR}/hosts.map"
  MNT_WWW_DIR="/var/www/${WWW_BASE_DIR}"

  touch "${HOSTS_MAP_PATH}"

  MAP_RECORD="${DOMAIN}:${WWW_DIR}"

  if ! grep -q ":$WWW_DIR$" "${HOSTS_MAP_PATH}"; then
    # shellcheck disable=SC2015
    sh -c "echo '${MAP_RECORD}' >> ${HOSTS_MAP_PATH}" \
      && message_success "Domain $DOMAIN is mapped to the directory $WWW_DIR in the file $HOSTS_MAP_PATH" \
      || message_failure "Domain $DOMAIN mapping to the directory $WWW_DIR in the file $HOSTS_MAP_PATH error"
  else
    message_failure "Host with such mapped directory already exists in workspace"
  fi

  IS_WWW_DIR_DEFINED=1
done

"${SCRIPT_DIR}/mount_www.sh"

CONFIG_NAME="${DOMAIN//./-}"
CONFIG_FILE="${CONFIG_NAME}.conf"
CONFIG_APACHE_PATH="${HOSTS_APACHE_DIR}/${CONFIG_FILE}"
CONFIG_NGINX_PATH="${HOSTS_NGINX_DIR}/${CONFIG_FILE}"

LOGS_DIR="${WORKSPACE_DIR}/logs"
LOGS_APACHE_DIR="${LOGS_DIR}/apache/${CONFIG_NAME}"
LOGS_NGINX_DIR="${LOGS_DIR}/nginx/${CONFIG_NAME}"
CERTS_DIR="${WORKSPACE_DIR}/data/certs"

CERT_PEM="${DOMAIN}-cert.pem"
CERT_KEY="${DOMAIN}-cert.key"

IS_HOST_CONFIG_CREATED=0
NEED_CERT=0

if [[ ! -f "${CONFIG_APACHE_PATH}" || ! -f "${CONFIG_NGINX_PATH}" ]]; then
  read -r -p "Choose scheme (1 - HTTP, 2 - HTTPS, 3 - HTTP + HTTPS) [1]: " SCHEME
  SCHEME=${SCHEME:-1}

  read -r -p "Select a host type (common/laravel/node) [common]: " HOST_TYPE
  HOST_TYPE=$(to_lowercase "${HOST_TYPE:-common}")

  if [ ! -f "${CONFIG_APACHE_PATH}" ]; then
    read -r -d '' APACHE_HTTP_CONFIG <<-EOM
			<VirtualHost *:80>
EOM

    read -r -d '' APACHE_HTTPS_CONFIG <<-EOM
			<VirtualHost *:443>
EOM

    read -r -d '' APACHE_HTTP_HTTPS_CONFIG <<-EOM
			<VirtualHost *:80 *:443>
EOM

    read -r -d '' APACHE_CERTS_CONFIG <<-EOM
			    SSLEngine on
			    SSLCertificateFile "/var/certs/${CERT_PEM}"
			    SSLCertificateKeyFile "/var/certs/${CERT_KEY}"
EOM
  fi

  if [ ! -f "${CONFIG_NGINX_PATH}" ]; then
    read -r -d '' NGINX_HTTP_CONFIG <<-EOM
			    listen 80;
EOM

    read -r -d '' NGINX_HTTPS_CONFIG <<-EOM
			    listen 443 ssl;
EOM

    read -r -d '' NGINX_HTTP_HTTPS_CONFIG <<-EOM
			    ${NGINX_HTTP_CONFIG}
			    ${NGINX_HTTPS_CONFIG}
EOM

    read -r -d '' NGINX_CERTS_CONFIG <<-EOM
			    ssl_certificate /var/certs/${CERT_PEM};
			    ssl_certificate_key /var/certs/${CERT_KEY};
EOM
  fi

  case "$HOST_TYPE" in
  laravel)
    read -r -d '' APACHE_REDIRECT_TO_HTTPS <<-EOM
			<VirtualHost *:80>
			    ServerName ${DOMAIN}
			    Redirect permanent / https://${DOMAIN}
			</VirtualHost>
EOM

    read -r -d '' NGINX_REDIRECT_TO_HTTPS <<-EOM
			server {
			    listen 80;
			    server_name ${DOMAIN};
			    return 301 https://${DOMAIN}\$request_uri;
			}
EOM
    ;;
  node)
    NODE_PORTS_MAP_PATH="${WORKSPACE_DIR}/node-ports.map"

    touch "${NODE_PORTS_MAP_PATH}"

    IS_NODE_PORT_DEFINED=0

    until [ "${IS_NODE_PORT_DEFINED}" -eq 1 ]; do
      read -r -p "Set port of Node application (49001-49150): " NODE_PORT

      if [[ $NODE_PORT -lt 49001 || $NODE_PORT -gt 49150 ]]; then
        message_colored "You must set the port in the range 49001 - 49150!" "FAILURE" \
          && continue
      fi

      NODE_PORTS_MAP_RECORD="${DOMAIN}:${NODE_PORT}"

      if ! grep -q ":$NODE_PORT$" "${NODE_PORTS_MAP_PATH}"; then
        # shellcheck disable=SC2015
        sh -c "echo '${NODE_PORTS_MAP_RECORD}' >> ${NODE_PORTS_MAP_PATH}" \
          && message_success "Domain $DOMAIN is mapped to the port $NODE_PORT of node service in the file $NODE_PORTS_MAP_PATH" \
          || message_failure "Domain $DOMAIN mapping to the port $NODE_PORT of node service in the file $NODE_PORTS_MAP_PATH error"
      else
        message_failure "Host with such mapped port already exists in workspace" \
          && continue
      fi

      IS_NODE_PORT_DEFINED=1
    done

    NODE_UPSTREAM_NAME=$(to_snake_case "$WWW_BASE_DIR")
    ;;
  common|*)
    ;;
  esac

  case "$SCHEME" in
  2)
    APACHE_PORT_CONFIG=$APACHE_HTTPS_CONFIG
    APACHE_REDIRECT_TO_HTTPS=''
    NGINX_PORT_CONFIG=$HTTPS_CONFIG
    NGINX_REDIRECT_TO_HTTPS=''
    NEED_CERT=1
    ;;
  3)
    if [ "${HOST_TYPE}" != "laravel" ]; then
      APACHE_PORT_CONFIG=$APACHE_HTTP_HTTPS_CONFIG
      NGINX_PORT_CONFIG=$NGINX_HTTP_HTTPS_CONFIG
    else
      APACHE_PORT_CONFIG=$APACHE_HTTPS_CONFIG
      NGINX_PORT_CONFIG=$NGINX_HTTPS_CONFIG
    fi
    NEED_CERT=1
    ;;
  1|*)
    NGINX_PORT_CONFIG=$NGINX_HTTP_CONFIG
    NGINX_REDIRECT_TO_HTTPS=''
    NGINX_CERTS_CONFIG=''
    APACHE_PORT_CONFIG=$APACHE_HTTP_CONFIG
    APACHE_REDIRECT_TO_HTTPS=''
    APACHE_CERTS_CONFIG=''
    ;;
  esac

  if [ "$(is_wsl)" -eq 1 ]; then
    read -r -d '' APACHE_CERTS_CONFIG <<-EOM
			    SSLEngine on
			#    SSLCertificateFile "/var/certs/${CERT_PEM}"
			#    SSLCertificateKeyFile "/var/certs/${CERT_KEY}"
EOM

    read -r -d '' NGINX_CERTS_CONFIG <<-EOM
			#    ssl_certificate /var/certs/${CERT_PEM};
			#    ssl_certificate_key /var/certs/${CERT_KEY};
EOM
    NEED_CERT=0
  fi

  case "$HOST_TYPE" in
  laravel)
    { cat > "${CONFIG_APACHE_PATH}" <<-EOF
			${APACHE_PORT_CONFIG}
			    ServerName ${DOMAIN}
			    DocumentRoot "${MNT_WWW_DIR}/public"
			    DirectoryIndex index.php

			    SetEnvIf Request_URI "^/favicon\.ico$" do_not_log
			    SetEnvIf Request_URI "^/robots\.txt$" do_not_log

			    ErrorLog "/usr/local/apache2/logs/${CONFIG_NAME}/error.log"
			    LogLevel warn
			    CustomLog "/usr/local/apache2/logs/${CONFIG_NAME}/access.log" combined env=!do_not_log
			    ${APACHE_CERTS_CONFIG}

			    Header set X-Frame-Options "SAMEORIGIN"
			    Header set X-XSS-Protection "1; mode=block"
			    Header set X-Content-Type-Options "nosniff"

			    ErrorDocument 404 /index.php

			    AddDefaultCharset utf-8

			    <Directory ~ "/\.(?!well-known\/)">
			        Require all denied
			    </Directory>

			    <FilesMatch \.php$>
			        SetHandler "proxy:fcgi://php:9000"
			    </FilesMatch>

			    <Directory "${MNT_WWW_DIR}">
			        AllowOverride All
			        Options All
			        Require all granted
			    </Directory>
			</VirtualHost>

			${APACHE_REDIRECT_TO_HTTPS}
EOF
    } && message_success "Apache host configuration created $CONFIG_APACHE_PATH" \
      && IS_HOST_CONFIG_CREATED=1

    { cat > "${CONFIG_NGINX_PATH}" <<-EOF
			server {
			    ${NGINX_PORT_CONFIG}
			    server_name ${DOMAIN};
			    root ${MNT_WWW_DIR}/public;

			    error_log /var/log/nginx/${CONFIG_NAME}/error.log;
			    access_log /var/log/nginx/${CONFIG_NAME}/access.log;
			    ${NGINX_CERTS_CONFIG}

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

			${NGINX_REDIRECT_TO_HTTPS}
EOF
    } && message_success "nginx host configuration created $CONFIG_NGINX_PATH" \
      && IS_HOST_CONFIG_CREATED=1
    ;;
  node)
    { cat > "${CONFIG_APACHE_PATH}" <<-EOF
			${APACHE_PORT_CONFIG}
			    ServerName ${DOMAIN}

			    ErrorLog "/usr/local/apache2/logs/${CONFIG_NAME}/error.log"
			    LogLevel warn
			    CustomLog "/usr/local/apache2/logs/${CONFIG_NAME}/access.log" combined
			    ${APACHE_CERTS_CONFIG}

			    ProxyRequests off

			    <Proxy *>
			        Require all granted
			    </Proxy>

			    <Location />
			        ProxyPass http://node:${NODE_PORT}
			        ProxyPassReverse http://node:${NODE_PORT}
			    </Location>
			</VirtualHost>
EOF
    } && message_success "Apache host configuration created $CONFIG_APACHE_PATH" \
      && IS_HOST_CONFIG_CREATED=1

    { cat > "${CONFIG_NGINX_PATH}" <<-EOF
			upstream ${NODE_UPSTREAM_NAME} {
			    server node:${NODE_PORT};
			    keepalive 64;
			}

			server {
			    ${NGINX_PORT_CONFIG}
			    server_name ${DOMAIN};

			    error_log /var/log/nginx/${CONFIG_NAME}/error.log;
			    access_log /var/log/nginx/${CONFIG_NAME}/access.log;
			    ${NGINX_CERTS_CONFIG}

			    location / {
			        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
			        proxy_set_header X-Real-IP \$remote_addr;
			        proxy_set_header Host \$http_host;

			        proxy_http_version 1.1;
			        proxy_set_header Upgrade \$http_upgrade;
			        proxy_set_header Connection "upgrade";

			        proxy_pass http://${NODE_UPSTREAM_NAME};
			        proxy_redirect off;
			        proxy_read_timeout 240s;
			    }
			}
EOF
    } && message_success "nginx host configuration created $CONFIG_NGINX_PATH" \
      && IS_HOST_CONFIG_CREATED=1
    ;;
  common|*)
    { cat > "${CONFIG_APACHE_PATH}" <<-EOF
			${APACHE_PORT_CONFIG}
			    ServerName ${DOMAIN}
			    DocumentRoot "${MNT_WWW_DIR}"
			    DirectoryIndex index.php

			    ErrorLog "/usr/local/apache2/logs/${CONFIG_NAME}/error.log"
			    LogLevel warn
			    CustomLog "/usr/local/apache2/logs/${CONFIG_NAME}/access.log" combined
			    ${APACHE_CERTS_CONFIG}

			    <FilesMatch \.php$>
			        SetHandler "proxy:fcgi://php:9000"
			    </FilesMatch>

			    <Directory "${MNT_WWW_DIR}">
			        Options All
			        AllowOverride All
			        Require all granted
			    </Directory>
			</VirtualHost>
EOF
    } && message_success "Apache host configuration created $CONFIG_APACHE_PATH" \
      && IS_HOST_CONFIG_CREATED=1

    { cat > "${CONFIG_NGINX_PATH}" <<-EOF
			server {
			    ${NGINX_PORT_CONFIG}
			    index index.php;
			    server_name ${DOMAIN};
			    error_log /var/log/nginx/${CONFIG_NAME}/error.log;
			    access_log /var/log/nginx/${CONFIG_NAME}/access.log;
			    root ${MNT_WWW_DIR};
			    ${NGINX_CERTS_CONFIG}
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
    } && message_success "nginx host configuration created $CONFIG_NGINX_PATH" \
      && IS_HOST_CONFIG_CREATED=1
    ;;
  esac
else
  message_failure "Host configurations $CONFIG_APACHE_PATH and $CONFIG_NGINX_PATH already exists"
fi

if [ ! -d "$LOGS_APACHE_DIR" ]; then
  mkdir -p "$LOGS_APACHE_DIR" &&
    message_success "Apache logs directory created $LOGS_APACHE_DIR"
else
  message_failure "Apache logs directory $LOGS_APACHE_DIR already exists"
fi

if [ ! -d "$LOGS_NGINX_DIR" ]; then
  sudo mkdir -p "$LOGS_NGINX_DIR" &&
    message_success "nginx logs directory created $LOGS_NGINX_DIR"
else
  message_failure "nginx logs directory $LOGS_NGINX_DIR already exists"
fi

if [ "$(is_wsl)" -eq 1 ]; then
  HOSTS_PATH="/mnt/c/Windows/System32/drivers/etc/hosts"
else
  HOSTS_PATH="/etc/hosts"
fi

HOST_RECORD="127.0.0.1	${DOMAIN}"
HOST_RECORD_REGEX="127\.0\.0\.1\s*${DOMAIN}$"

if ! grep -q "${HOST_RECORD_REGEX}" "${HOSTS_PATH}"; then
  sudo sh -c "echo '\n${HOST_RECORD}' >> ${HOSTS_PATH}" \
    && message_success "Domain $DOMAIN is defined in the file $HOSTS_PATH"
else
  message_failure "Domain $DOMAIN is already defined in the file $HOSTS_PATH"
fi

if [ "${NEED_CERT}" -eq 1 ]; then
  # shellcheck disable=SC2015
  bash -c "${SCRIPT_DIR}/make_ssl_cert.sh ${DOMAIN} > /dev/null 2>&1" \
    && message_success "SSL certificate is generated ($CERT_PEM and $CERT_KEY) and put to the directory $CERTS_DIR" \
    || message_failure "Error when generating SSL certificate"
fi

if [[ "$(is_wsl)" -eq 0 && "${IS_HOST_CONFIG_CREATED}" -eq 1 ]]; then
  for SERVICE_NAME in ${SERVICES_NEED_WWW[*]}; do
    SERVICE_VARIABLE="SERVICE_$(to_snake_case "$(to_uppercase "$SERVICE_NAME")")"
    SERVICE=$(to_lowercase "$SERVICE_NAME")

    SERVICE_STATE=$(parse_env "$SERVICE_VARIABLE" "${ENV_PATH}")
    case "$SERVICE_STATE" in
    0)
      ;;
    1|*)
      ${DC} restart "${SERVICE}"
      ;;
    esac
  done
fi

PHP_IMAGE_DIR="${WORKSPACE_DIR}/images/node"
PM2_CONFIG_PATH="${PHP_IMAGE_DIR}/ecosystem.config.js"
PM2_CONFIG_EXAMPLE_PATH="${PHP_IMAGE_DIR}/ecosystem.config.js.example"

if [ "${HOST_TYPE}" = "node" ]; then
  message_colored "Attention!!! You should manually add configuration of your Node in file ${PM2_CONFIG_PATH} like in example from file ${PM2_CONFIG_EXAMPLE_PATH}" "FAILURE"
fi