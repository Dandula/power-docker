FROM php:8.0-fpm

LABEL maintainer="Vladyslav Revenko <dandular@gmail.com>"

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG NODE_VER=lts

COPY --chown=root:root fakesendmail.sh /etc/fakesendmail.sh

RUN chmod 755 /etc/fakesendmail.sh \
    && mkdir -p /var/mail/sendmail \
    && chmod 777 /var/mail/sendmail

RUN apt-get update && apt-get install -y \
        mc \
        unzip \
        openssh-client \
        wget \
        curl \
#        sendmail \
        msmtp \
        git \
# apcu
    && mkdir -p /usr/src/php/ext/apcu \
    && curl -fsSL https://pecl.php.net/get/apcu-5.1.22 | tar xvz -C "/usr/src/php/ext/apcu" --strip 1 \
    && docker-php-ext-install apcu \
# bz2
    && apt-get install -y libbz2-dev \
    && docker-php-ext-install bz2 \
# enchant
    && apt-get install -y libenchant-2-dev \
    && docker-php-ext-install enchant \
# exif
    && docker-php-ext-install exif \
# gd
    && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
# gettext
    && docker-php-ext-install gettext \
# imagick
    && apt-get install -y libmagickwand-dev \
    && mkdir -p /usr/src/php/ext/imagick \
    && curl -fsSL https://pecl.php.net/get/imagick-3.7.0 | tar xvz -C "/usr/src/php/ext/imagick" --strip 1 \
    && docker-php-ext-install imagick \
# intl
    && docker-php-ext-install intl \
# memcached
    && apt-get install -y \
        libmemcached-dev \
        zlib1g-dev \
    && mkdir -p /usr/src/php/ext/memcached \
    && curl -fsSL https://pecl.php.net/get/memcached-3.2.0 | tar xvz -C "/usr/src/php/ext/memcached" --strip 1 \
    && docker-php-ext-install memcached \
# mongodb
    && mkdir -p /usr/src/php/ext/mongodb \
    && curl -fsSL https://pecl.php.net/get/mongodb-1.15.0 | tar xvz -C "/usr/src/php/ext/mongodb" --strip 1 \
    && docker-php-ext-install mongodb \
# mysqli
    && docker-php-ext-install mysqli \
# odbc
    && apt-get install -y unixodbc-dev \
    && docker-php-source extract \
    && cd /usr/src/php/ext/odbc \
    && phpize \
    && sed -ri 's@^ *test +"\$PHP_.*" *= *"no" *&& *PHP_.*=yes *$@#&@g' configure \
    && ./configure --with-unixODBC=shared,/usr \
    && docker-php-ext-install odbc \
# pdo_mysql
    && docker-php-ext-install pdo_mysql \
# pdo_pgsql
    && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo_pgsql \
# redis
    && mkdir -p /usr/src/php/ext/redis \
    && curl -fsSL https://pecl.php.net/get/redis-5.3.7 | tar xvz -C "/usr/src/php/ext/redis" --strip 1 \
    && docker-php-ext-install redis \
# soap
    && apt-get install -y libxml2-dev \
    && docker-php-ext-install soap \
# sockets
    && docker-php-ext-install sockets \
# timezonedb
    && mkdir -p /usr/src/php/ext/timezonedb \
    && curl -fsSL https://pecl.php.net/get/timezonedb-2023.3 | tar xvz -C "/usr/src/php/ext/timezonedb" --strip 1 \
    && docker-php-ext-install timezonedb \
# xdebug
    && mkdir -p /usr/src/php/ext/xdebug \
    && curl -fsSL https://pecl.php.net/get/xdebug-3.1.6 | tar xvz -C "/usr/src/php/ext/xdebug" --strip 1 \
    && docker-php-ext-install xdebug \
# xmlrpc
    && apt-get install -y libxml2-dev \
    && mkdir -p /usr/src/php/ext/xmlrpc \
    && curl -fsSL https://pecl.php.net/get/xmlrpc-1.0.0RC3 | tar xvz -C "/usr/src/php/ext/xmlrpc" --strip 1 \
    && docker-php-ext-install xmlrpc \
# xsl
    && apt-get install -y libxslt-dev \
    && docker-php-ext-install xsl \
# removing tempory files
    && docker-php-source delete

RUN VERSION=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && ARCHITECTURE=$(uname -m) \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/$ARCHITECTURE/$VERSION \
    && mkdir -p /tmp/blackfire \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && mkdir -p /tmp/blackfire-cli \
    && curl -A "Docker" -L https://blackfire.io/api/v1/releases/cli/linux/$ARCHITECTURE | tar zxp -C /tmp/blackfire-cli \
    && mv /tmp/blackfire-cli/blackfire /usr/bin/blackfire \
    && rm -rf /tmp/blackfire /tmp/blackfire-probe.tar.gz /tmp/blackfire-cli

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer

RUN sed -i '/#!\/bin\/sh/achown docker:docker /var/log/php' /usr/local/bin/docker-php-entrypoint \
    && sed -i '/#!\/bin\/sh/amkdir -p /var/log/php' /usr/local/bin/docker-php-entrypoint \
## sendmail
#    && sed -i '/#!\/bin\/sh/asudo service sendmail restart' /usr/local/bin/docker-php-entrypoint \
#    && sed -i '/#!\/bin\/sh/asudo echo "$(hostname -i)\t$(hostname) $(hostname).localhost" >> /etc/hosts' /usr/local/bin/docker-php-entrypoint
# mmsmtp
    && sed -i '/#!\/bin\/sh/achmod 700 /var/log/msmtp' /usr/local/bin/docker-php-entrypoint \
    && sed -i '/#!\/bin\/sh/asudo chown docker:msmtp /var/log/msmtp' /usr/local/bin/docker-php-entrypoint \
    && sed -i '/#!\/bin\/sh/amkdir -p /var/log/msmtp' /usr/local/bin/docker-php-entrypoint \
    && sed -i '/#!\/bin\/sh/afind ~/.ssh -type f ! -name "*.*" ! -name ".gitkeep" ! -name "config" ! -name "known_hosts" -exec ssh-add {} +' /usr/local/bin/docker-php-entrypoint \
    && sed -i '/#!\/bin\/sh/aeval "$(ssh-agent -s)"' /usr/local/bin/docker-php-entrypoint \
    && sed -i '/#!\/bin\/sh/afind ~/.ssh -type f ! -name "*.pub" ! -name ".gitkeep" ! -name "config" ! -name "known_hosts" -exec chmod 600 {} +' /usr/local/bin/docker-php-entrypoint \
    && sed -i '/#!\/bin\/sh/asudo find ~/.ssh -type f ! -name ".gitkeep" ! -name "config" ! -name "known_hosts" -exec chown docker {} +' /usr/local/bin/docker-php-entrypoint \
    && sed -i '/#!\/bin\/sh/asudo cp -a /home/docker/certs/* ~/.ssh 2>/dev/null' /usr/local/bin/docker-php-entrypoint \
    && sed -i '/#!\/bin\/sh/afind ~/.ssh -type f ! -name ".gitkeep" ! -name "config" ! -name "known_hosts" -delete' /usr/local/bin/docker-php-entrypoint \
    && sed -i '/#!\/bin\/sh/amkdir -p /home/docker/.ssh' /usr/local/bin/docker-php-entrypoint

RUN apt-get install -y sudo \
    && adduser -u ${USER_ID} --disabled-password --gecos '' docker \
    && groupmod -g ${GROUP_ID} docker \
    && adduser docker sudo \
    && echo 'docker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER "${USER_ID}:${GROUP_ID}"

ENV NVM_DIR=/home/docker/.nvm
ENV NODE_VER=${NODE_VER}

RUN ["/bin/bash", "-c", "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash \
    && source ${NVM_DIR}/nvm.sh \
    && nvm install ${NODE_VER} \
    && nvm alias default ${NODE_VER} \
    && nvm use default"]

RUN sudo apt-get clean \
    && sudo rm -r /var/lib/apt/lists/*

EXPOSE 9000

CMD ["php-fpm"]