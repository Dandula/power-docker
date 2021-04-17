ARG PHP_VER

FROM php:${PHP_VER}-fpm

LABEL maintainer="Vladyslav Revenko <dandular@gmail.com>"

ARG USER_ID=1000
ARG GROUP_ID=1000

COPY fakesendmail.sh /etc/fakesendmail.sh

RUN chown root:root /etc/fakesendmail.sh \
    && chmod 755 /etc/fakesendmail.sh \
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
    && pecl install apcu-5.1.20 \
    && docker-php-ext-enable apcu \
# bz2
    && apt-get install -y libbz2-dev \
    && docker-php-ext-install bz2 \
# enchant
    && apt-get install -y libenchant-dev \
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
    && pecl install imagick-3.4.4 \
    && docker-php-ext-enable imagick \
# intl
    && docker-php-ext-install intl \
# memcached
    && apt-get install -y \
        libmemcached-dev \
        zlib1g-dev \
    && pecl install memcached-3.1.5 \
    && docker-php-ext-enable memcached \
# mongodb
    && pecl install mongodb-1.9.1 \
    && docker-php-ext-enable mongodb \
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
    && pecl install redis-5.3.4 \
    && docker-php-ext-enable redis \
# soap
    && apt-get install -y libxml2-dev \
    && docker-php-ext-install soap \
# sockets
    && docker-php-ext-install sockets \
# timezonedb
    && pecl install timezonedb-2021.1 \
    && docker-php-ext-enable timezonedb \
# xdebug
    && pecl install xdebug-3.0.4 \
    && docker-php-ext-enable xdebug \
# xmlrpc
    && apt-get install -y libxml2-dev \
    && docker-php-ext-install xmlrpc \
# xsl
    && apt-get install -y libxslt-dev \
    && docker-php-ext-install xsl \
# removing tempory files
    && docker-php-source delete

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y \
        nodejs \
        build-essential

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
    && sed -i '/#!\/bin\/sh/asudo cp -a /home/docker/certs/* ~/.ssh' /usr/local/bin/docker-php-entrypoint \
    && sed -i '/#!\/bin\/sh/afind ~/.ssh -type f ! -name ".gitkeep" ! -name "config" ! -name "known_hosts" -delete' /usr/local/bin/docker-php-entrypoint \
    && sed -i '/#!\/bin\/sh/amkdir -p /home/docker/.ssh' /usr/local/bin/docker-php-entrypoint

RUN apt-get install -y sudo \
    && adduser -u ${USER_ID} --disabled-password --gecos '' docker \
    && groupmod -g ${GROUP_ID} docker \
    && adduser docker sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/*

USER "${USER_ID}:${GROUP_ID}"

EXPOSE 9000

CMD ["php-fpm"]