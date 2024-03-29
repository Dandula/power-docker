FROM ubuntu

LABEL maintainer="Vladyslav Revenko <dandular@gmail.com>"

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG TIMEZONE=UTC
ARG PHP_VER
ARG NODE_VER=lts

ENV TZ=${TIMEZONE}

COPY --chown=root:root fakesendmail.sh /etc/fakesendmail.sh
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone \
    && chmod 755 /etc/fakesendmail.sh \
    && mkdir -p /var/mail/sendmail \
    && chmod 777 /var/mail/sendmail \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

RUN apt-get update \
    && apt-get install -y software-properties-common \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        cron \
        supervisor \
        nano \
        curl \
        php${PHP_VER}-cli \
        php${PHP_VER}-dev \
        php-pear \
        pkg-config \
#        sendmail \
        msmtp \
    && find /etc/php/${PHP_VER}/cli/conf.d -name "*-opcache.ini" | xargs rm \
# xml
    && apt-get install -y php${PHP_VER}-xml \
# apcu
    && pecl install apcu-5.1.22 \
# bz2
    && apt-get install -y php${PHP_VER}-bz2 \
# curl
    && apt-get install -y php${PHP_VER}-curl \
# enchant
    && apt-get install -y php${PHP_VER}-enchant \
# exif
    && apt-get install -y php${PHP_VER}-exif \
# gd
    && apt-get install -y php${PHP_VER}-gd \
# gettext
    && apt-get install -y php${PHP_VER}-gettext \
#imagick
    && apt-get install -y libmagickwand-dev \
    && pecl install imagick-3.7.0 \
# intl
    && apt-get install -y php${PHP_VER}-intl \
# mbstring
    && apt-get install -y php${PHP_VER}-mbstring \
# memcached
    && apt-get install -y \
        libmemcached-dev \
        zlib1g-dev \
    && pecl install memcached-3.2.0 \
# mongodb
    && pecl install mongodb-1.15.1 \
# mysqli
    && apt-get install -y php${PHP_VER}-mysqli \
# odbc
    && apt-get install -y php${PHP_VER}-odbc \
# pdo_mysql
    && apt-get install -y php${PHP_VER}-mysql \
# pdo_pgsql
    && apt-get install -y php${PHP_VER}-pgsql \
# redis
    && pecl install redis-5.3.7 \
# soap
    && apt-get install -y php${PHP_VER}-soap \
# sockets
    && apt-get install -y php${PHP_VER}-sockets \
# sqlite3
    && apt-get install -y php${PHP_VER}-sqlite3 \
# timezonedb
    && pecl install timezonedb-2023.3 \
# xdebug
    && pecl install xdebug-3.1.6 \
# xmlrpc
    && apt-get install -y php${PHP_VER}-xmlrpc \
# xsl
    && apt-get install -y php${PHP_VER}-xsl

RUN apt-get install -y sudo \
    && adduser -u ${USER_ID} --disabled-password --gecos '' docker \
    && groupmod -g ${GROUP_ID} docker \
    && adduser docker sudo \
    && echo 'docker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN mkdir -p /var/log/supervisor \
    && mkdir -p /var/log/cron \
    && mkdir -p /var/log/msmtp \
    && chown docker:msmtp /var/log/msmtp \
    && chmod 700 /var/log/msmtp

USER "${USER_ID}:${GROUP_ID}"

ENV NVM_DIR=/home/docker/.nvm
ENV NODE_VER=${NODE_VER}

RUN ["/bin/bash", "-c", "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash \
    && source ${NVM_DIR}/nvm.sh \
    && nvm install ${NODE_VER} \
    && nvm alias default ${NODE_VER} \
    && nvm use default"]

ENV NODE_PATH ${NVM_DIR}/v${NODE_VER}/lib/node_modules
ENV PATH ${NVM_DIR}/versions/node/v${NODE_VER}/bin:$PATH

RUN npm install pm2@latest -g \
    && sudo apt-get clean \
    && sudo rm -r /var/lib/apt/lists/*

CMD ["docker-entrypoint.sh"]