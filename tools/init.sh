#!/bin/bash

CLEAN_INSTALL=0

for VAR in "$@"; do
  case "$VAR" in
  --clean-install)
    CLEAN_INSTALL=1
    ;;
  esac
done

function my_cp() {
  if [ "${CLEAN_INSTALL}" -eq 0 ]; then
    cp -n "$@"
  else
    cp "$@"
  fi
}

function my_ln() {
  if [ "${CLEAN_INSTALL}" -eq 0 ]; then
    ln -sn "$@"
  else
    ln -snf "$@"
  fi
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR%/*}"

DC="${SCRIPT_DIR}/dc.sh"

# shellcheck source=scripts/parse_env.sh
. "${SCRIPT_DIR}/scripts/parse_env.sh"
# shellcheck source=scripts/statuses.sh
. "${SCRIPT_DIR}/scripts/statuses.sh"
# shellcheck source=scripts/detect_wsl.sh
. "${SCRIPT_DIR}/scripts/detect_wsl.sh"

shopt -s extglob

cd "$WORKSPACE_DIR" || exit

find tools -type f -iname "*.sh" -exec chmod +x {} \;

my_cp .env.example .env
my_cp images/php/php7.4.ini.example images/php/php7.4.ini
my_cp images/php/php8.0.ini.example images/php/php8.0.ini
my_cp images/php/msmtprc.example images/php/msmtprc
my_cp images/mysql/my.cnf.example images/mysql/my.cnf
my_cp images/redis/redis.conf.example images/redis/redis.conf
my_cp images/rabbitmq/rabbitmq.conf.example images/rabbitmq/rabbitmq.conf
my_cp images/schedule/supervisord.conf.example images/schedule/supervisord.conf
my_cp images/schedule/additional.ini.example images/schedule/additional.ini
my_cp "$WORKSPACE_DIR/services/examples/"!(docker-compose.all.yml) "$WORKSPACE_DIR/services"
my_cp "$WORKSPACE_DIR/services/examples/docker-compose.all.yml" "$WORKSPACE_DIR/docker-compose.yml"

GID=$(id -g)
ENV_PATH="${WORKSPACE_DIR}/.env"

sed -i "s/^USER_ID=.*/USER_ID=$UID/" "$ENV_PATH"

sed -i "s/^GROUP_ID=.*/GROUP_ID=$GID/" "$ENV_PATH"

DB_USER=$(parse_env "DB_USER" "${ENV_PATH}")
read -er -p "Enter DB user: " -i "$DB_USER" DB_USER
sed -i "s/^DB_USER=.*/DB_USER=$DB_USER/" "$ENV_PATH"

DB_PASSWORD=$(parse_env "DB_PASSWORD" "${ENV_PATH}")
read -er -p "Enter DB password: " -i "$DB_PASSWORD" DB_PASSWORD
sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=$DB_PASSWORD/" "$ENV_PATH"

BASICAUTH_USERNAME=$(parse_env "BASICAUTH_USERNAME" "${ENV_PATH}")
read -er -p "Enter basic authentication username: " -i "$BASICAUTH_USERNAME" BASICAUTH_USERNAME
sed -i "s/^BASICAUTH_USERNAME=.*/BASICAUTH_USERNAME=$BASICAUTH_USERNAME/" "$ENV_PATH"

BASICAUTH_PASSWORD=$(parse_env "BASICAUTH_PASSWORD" "${ENV_PATH}")
read -er -p "Enter basic authentication password: " -i "$BASICAUTH_PASSWORD" BASICAUTH_PASSWORD
sed -i "s/^BASICAUTH_PASSWORD=.*/BASICAUTH_PASSWORD=$BASICAUTH_PASSWORD/" "$ENV_PATH"

TIMEZONE=$(cat /etc/timezone)
read -er -p "Enter timezone [UTC]: " -i "$TIMEZONE" TIMEZONE
if [ -z "$TIMEZONE" ]; then
  TIMEZONE="UTC"
fi
sed -i "s%^TIMEZONE=.*%TIMEZONE=$TIMEZONE%" "$ENV_PATH"

PHP_VER=$(parse_env "PHP_VER" "${ENV_PATH}")
read -er -p "Enter PHP version (7.4/8.0) [7.4]: " -i "$PHP_VER" PHP_VER
case "$PHP_VER" in
8.0)
  ;;
7.4|*)
  PHP_VER="7.4"
  ;;
esac
sed -i "s%^PHP_VER=.*%PHP_VER=$PHP_VER%" "$ENV_PATH"

message_success "Setup environment variables $ENV_PATH"

PHP_IMAGE_DIR="${WORKSPACE_DIR}/images/php"
if [ "$(is_wsl)" -eq 1 ]; then
  XDEBUG_CLIENT_HOST="host.docker.internal"
else
  XDEBUG_CLIENT_HOST="172.17.0.1"
fi

# shellcheck disable=SC2015
find "${PHP_IMAGE_DIR}" -name "php*.ini" -exec sed -i "s%^xdebug\.client_host.*%xdebug.client_host               = $XDEBUG_CLIENT_HOST%" {} + \
  && message_success "xDebug at php.ini successfully configured" \
  || message_failure "xDebug at php.ini configuration error"

# shellcheck disable=SC2015
find "${PHP_IMAGE_DIR}" -name "php*.ini" -exec sed -i "s%^date\.timezone.*%date.timezone                = \"$TIMEZONE\"%" {} + \
  && message_success "Timezone at php.ini successfully configured" \
  || message_failure "Timezone at php.ini configuration error"

CA_BUNDLE_PATH_LOCAL="${WORKSPACE_DIR}/data/certs/ca/cacert.pem"
CA_BUNDLE_PATH_IMAGE="/usr/local/etc/ca/cacert.pem"
# shellcheck disable=SC2015
wget --no-check-certificate -c -N -O "${CA_BUNDLE_PATH_LOCAL}" https://curl.se/ca/cacert.pem > /dev/null 2>&1 \
  && find "${PHP_IMAGE_DIR}" -name "php*.ini" -exec sed -i "s%^curl\.cainfo.*%curl.cainfo                  = \"$CA_BUNDLE_PATH_IMAGE\"%" {} + \
  && find "${PHP_IMAGE_DIR}" -name "php*.ini" -exec sed -i "s%^openssl\.cafile.*%openssl.cafile               = \"$CA_BUNDLE_PATH_IMAGE\"%" {} + \
  && message_success "Certificate Authority (CA) bundle at php.ini successfully configured" \
  || message_failure "Certificate Authority (CA) bundle at php.ini configuration error"

RABBITMQ_CONFIG_FILEPATH="${WORKSPACE_DIR}/images/rabbitmq/rabbitmq.conf"
# shellcheck disable=SC2015
sed -i "s/# default_user = .*/default_user = ${DB_USER}/" "$RABBITMQ_CONFIG_FILEPATH" \
  && sed -i "s/# default_pass = .*/default_pass = ${DB_PASSWORD}/" "$RABBITMQ_CONFIG_FILEPATH" \
  && message_success "Credentials at rabbitmq.conf successfully configured" \
  || message_failure "Credentials at rabbitmq.conf configuration error"

WWW_DIR="${WORKSPACE_DIR}/www"
PHPMEMADMIN_REPO_NAME="phpmemadmin"
PHPMEMADMIN_BRANCH="master"
PHPMEMADMIN_OLD_DIR="${WWW_DIR}/${PHPMEMADMIN_REPO_NAME}-${PHPMEMADMIN_BRANCH}"
PHPMEMADMIN_DIR="${WWW_DIR}/phpmemadmin"
PHPMEMADMIN_CONFIG_DIR="${PHPMEMADMIN_DIR}/app"
PHPMEMADMIN_CONFIG_FILEPATH="${PHPMEMADMIN_CONFIG_DIR}/.config"
# shellcheck disable=SC2015
wget --no-check-certificate -c -O - "https://github.com/clickalicious/${PHPMEMADMIN_REPO_NAME}/archive/${PHPMEMADMIN_BRANCH}.tar.gz" 2>/dev/null | tar -xz -C "${WWW_DIR}" \
  && mv "${PHPMEMADMIN_OLD_DIR}"/{.,}* "${PHPMEMADMIN_DIR}" > /dev/null 2>&1 \
  || rm -r "${PHPMEMADMIN_OLD_DIR}" \
  && docker run --rm -it \
    -v "${PHPMEMADMIN_DIR}:/app" \
    -u "${UID}:${GID}" \
    composer install --no-scripts \
  && my_cp "$PHPMEMADMIN_CONFIG_DIR/.config.dist" "$PHPMEMADMIN_CONFIG_FILEPATH" \
  && sed -i "s%.*\"username\".*%  \"username\": \"admin\",%" "$PHPMEMADMIN_CONFIG_FILEPATH" \
  && sed -i "s%.*\"password\".*%  \"password\": \"secret\",%" "$PHPMEMADMIN_CONFIG_FILEPATH" \
  && sed -i "s%.*\"host\".*%        \"host\": \"memcached\",%" "$PHPMEMADMIN_CONFIG_FILEPATH" \
  && message_success "phpMemAdmin is installed and configured" \
  || message_failure "phpMemAdmin installation error"

# shellcheck disable=SC2015
docker run --rm -it \
  -v "${WWW_DIR}/opcache-gui:/app" \
  -u "${UID}:${GID}" \
  composer require --ignore-platform-reqs amnuts/opcache-gui > /dev/null 2>&1 \
  && message_success "opcache-gui is installed and configured" \
  || message_failure "opcache-gui installation error"

APCU_FILEPATH="${WWW_DIR}/apcu/apc.php"
# shellcheck disable=SC2015
wget --no-check-certificate -c -O "${WWW_DIR}/apcu/apc.php" https://raw.githubusercontent.com/krakjoe/apcu/master/apc.php > /dev/null 2>&1 \
  && sed -i "s%.*'ADMIN_USERNAME'.*%defaults('ADMIN_USERNAME','admin');%" "$APCU_FILEPATH" \
  && sed -i "s%.*'ADMIN_PASSWORD'.*%defaults('ADMIN_PASSWORD','secret');%" "$APCU_FILEPATH" \
  && message_success "APCu is installed and configured" \
  || message_failure "APCu installation error"

if [ "$(is_wsl)" -eq 0 ]; then
  HOSTS_PATH="/etc/hosts"
  HOSTS_LINK="${WORKSPACE_DIR}/hosts.link"
  # shellcheck disable=SC2015
  my_ln "$HOSTS_PATH" "$HOSTS_LINK" > /dev/null 2>&1 \
    && message_success "The link ${HOSTS_LINK} to hosts file has been created" \
    || message_failure "The link ${HOSTS_LINK} to hosts file creation error"

  # shellcheck disable=SC2015
  sudo sudo apt-get update > /dev/null 2>&1 \
    && sudo apt-get install -y libnss3-tools > /dev/null 2>&1 \
    && wget --no-check-certificate -c https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64 > /dev/null 2>&1 \
    && sudo mv mkcert-v1.4.3-linux-amd64 /usr/local/bin/mkcert \
    && sudo chmod +x /usr/local/bin/mkcert \
    && mkcert -install > /dev/null 2>&1 \
    && message_success "mkcert is installed" \
    || message_failure "mkcert installation error"
fi

"${SCRIPT_DIR}/config.sh"

if [ "$(is_wsl)" -eq 0 ]; then
  ${DC} build
fi