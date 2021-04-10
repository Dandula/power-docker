# PowerDocker Guide

## Contents
1. [About PowerDocker](#about-powerdocker)
1. [Downloading & Installation](#downloading-&-installation)
    1. [Downloading via GIT](#downloading-via-git)
    2. [Downloading via Wget](#downloading-via-wget)
    3. [Downloading via cURL](#downloading-via-curl)
    4. [Installation](#installation)
2. [Available Services](#available-services)
3. [CLI Tools](#cli-tools)
4. [WEB Tools](#web-tools)
5. [File Structure](#file-structure)
6. [Helpful](#helpful)
    1. [Workspace Run in the Background](#workspace-run-in-the-background)
    2. [Workspace Stopping](#workspace-stopping)
    3. [Typical Usage Example](#typical-usage-example)
    4. [Performance Enhancement](#performance-enhancement)
    5. [Setup xDebug for PhpStorm](#setup-xdebug-for-phpstorm)
        - [For test PHP CLI xDebug](#for-test-php-cli-xdebug)
    6. [SSL certificates on WSL](#ssl-certificates-on-wsl)



## About PowerDocker
**PowerDocker** - a workspace using Docker for WEB development.  

PowerDocker basic principles:
1. Focusing primarily on PHP development as well as Laravel
2. Most needed PHP extensions out of the box
3. Availability of services for basic Laravel development tasks
4. Easy access to logs and configs
5. Automation of routine processes with standard Linux tools
6. Maximum use of official images from Docker Hub
7. Minimum set of necessary software on the host



## Downloading & Installation
You need to have Wget and tar installed necessarily and depending on how you install it,
you may need GIT or cURL to install this workspace:  
`sudo apt-get update && sudo apt-get install -y wget tar`  
or  
`sudo apt-get update && sudo apt-get install -y wget tar git`  
or  
`sudo apt-get update && sudo apt-get install -y wget tar curl`.

And of course, you need to have Docker installed:
https://www.docker.com/products/docker-desktop.

### Downloading via GIT
Execute: `git clone https://github.com/Dandula/power-docker.git`

### Downloading via Wget
Execute: `wget -c https://github.com/Dandula/power-docker/archive/main.tar.gz -O - | tar -xz`

### Downloading via cURL
Execute: `curl -sL https://github.com/Dandula/power-docker/archive/main.tar.gz | tar -xz`

### Installation
Execute: `cd power-docker && chmod +x ./tools/init.sh && ./tools/init.sh`



## Available Services
1. WebServer: nginx
2. PHP (v7.4/8.0) with MSMTP as an MTA (for `mail()`). Also has Midnight Commander, Wget, cURL, GIT, Composer, npm.
3. MySQL (v5.7)
4. MongoDB
5. Memcached
6. Redis
7. RabbitMQ & Management Plugin
8. Schedule: supervisor & CRON
9. phpMyAdmin
10. Adminer
11. Mongo-Express
12. phpRedisAdmin



## CLI Tools
1. [**init.sh**](./tools/init.sh) - initializing the workspace  
   _Example:_ execute `./tools/init.sh [--clean-install]` for the initial setup.  
   **Important!** Option `--clean-install` overwrite config and not delete user data!
2. [**host_add.sh**](./tools/host_add.sh) - add a new host  
   _Example:_ execute `<path_to_tools>/host_add.sh example.loc`.
3. [**host_del.sh**](./tools/host_del.sh) - delete the host  
   _Example:_ execute `<path_to_tools>/host_del.sh example.loc`.  
   **Important!** This command does not delete the directory with the sources of the host!
4. [**composer.sh**](./tools/init.sh) - Composer command  
   _Example:_ execute `../../tools/composer.sh composer require <package>` in the project directory `./www/<project>`.
5. [**npm.sh**](./tools/init.sh) - NPM command  
   _Example:_ execute `../../tools/npm.sh install --save-dev <package>` in the project directory `./www/<project>`.
6. [**mysql_export.sh**](./tools/mysql_export.sh) - export MySQL database dump to the directory `./data/dumps/mysql`  
   _Example:_ execute `<path_to_tools>/mysql_export.sh <database>` in any directory while the workspace is running.
7. [**mysql_import.sh**](./tools/mysql_import.sh) - import MySQL database dump from the directory `./data/dumps/mysql`  
   _Example:_ execute `<path_to_tools>/mysql_import.sh <dump_filename>` in any directory while the workspace is running.
8. [**mongo_export.sh**](./tools/mongo_export.sh) - export Mongo database dump to the directory `./data/dumps/mongo`  
   _Example:_ execute `<path_to_tools>/mongo_export.sh <database>` in any directory while the workspace is running.
9. [**mongo_import.sh**](./tools/mongo_import.sh) - import Mongo database dump from the directory `./data/dumps/mongo`  
   _Example:_ execute `<path_to_tools>/mongo_import.sh <dump_filename>` in any directory while the workspace is running.
10. [**make_cert.sh**](./tools/make_cert.sh) - make SSL certificate for a domain and put to the directory `./data/certs`  
    _Example:_ execute `<path_to_tools>/make_cert.sh <domain>` in any directory.  
    **Important!** This command not compatible with WSL. Browser must be installed at the same host as used `mkcert`!
11. [**make_ssh_cert.sh**](./tools/make_ssh_cert.sh) - make SSH certificate for SSH agent of php service  
    _Example:_ execute `<path_to_tools>/make_ssh_cert.sh <cert_filename> <comment_email>` in any directory.
    **Important!** You must run a new php container to apply the generated SSH agent key!
12. [**cron_example.sh**](./tools/cron_example.sh) - add CRON job example to the directory `./data/cron`  
    _Example:_ execute `<path_to_tools>/cron_example.sh <example_filename>` in any directory.
13. [**wsl/mkcert_install.bat**](./tools/wsl/mkcert_install.bat) - install mkcert to the Windows OS  
    _Example:_ execute `<path_to_tools>\wsl\mkcert_install.bat` in any directory.
14. [**wsl/make_cert.bat**](./tools/wsl/make_cert.bat) - make SSL certificate for a domain from the Windows OS and put to the directory `./data/certs`  
    _Example:_ execute `<path_to_tools>\wsl\make_cert.bat <domain>` in any directory.



## WEB Tools
1. http://localhost:8081 - phpMyAdmin
2. http://localhost:8082 - Adminer
3. http://localhost:8083 - Mongo-Express
4. http://localhost:8084 - opcache-gui
5. http://localhost:8085 - APCu
6. http://localhost:8086 - phpMemAdmin
7. http://localhost:8087 - phpRedisAdmin
8. http://localhost:8088 - RabbitMQ Management



## File Structure
`├─ data` - user data stored between runs  
`│  ├─ cache` - cache directory  
`│  │  ├─ .composer` - Composer home directory  
`│  │  └─ .npm` - npm home directory  
`│  ├─ certs` - SSL & SSH certificates of hosts  
`│  │  └─ mnt` - SSH certificates mounted to container of php service  
`│  ├─ cron` - configuration and scripts for running periodical jobs  
`│  ├─ databases` - database files  
`│  ├─ dumps` - generated database dump files  
`│  └─ mails` - saved emails sent by [`fakesendmail`](./images/php/fakesendmail.sh)  
`├─ hosts` - host configs for the web server  
`├─ images` - dockerfiles and configs for services  
`│  ├─ mysql` - MySQL service config  
`│  │  └─ my.cnf` - MySQL config  
`│  ├─ php` - PHP service config  
`│  │  ├─ 7.4.Dockerfile` - dockerfile of PHP v7.4 service  
`│  │  ├─ 8.0.Dockerfile` - dockerfile of PHP v8.0 service  
`│  │  ├─ fakesendmail.sh` - Bash script for saving emails instead of sending them _(copied into the image at build)_  
`│  │  ├─ msmtprc` - MSMTP config  
`│  │  ├─ php7.4.ini` - PHP v7.4 config  
`│  │  └─ php8.0.ini` - PHP v8.0 config  
`│  ├─ rabbitmq` - RabbitMQ service config  
`│  │  └─ rabbitmq.conf` - RabbitMQ config  
`│  ├─ redis` - Redis service config  
`│  │  └─ redis.conf` - Redis config  
`│  ├─ schedule` - schedule service config: supervisor and CRON jobs  
`│  │  ├─ additional.ini` - additional high-priority `php.ini` for CRON service  
`│  │  ├─ docker-entrypoint.sh` - Bash script for initialization CRON jobs and supervisor _(copied into the image at build)_  
`│  │  ├─ Dockerfile` - dockerfile of schedule service  
`│  │  ├─ fakesendmail.sh` - Bash script for saving emails instead of sending them _(copied into the image at build)_  
`│  ┴  └─ supervisord.conf` - supervisord config  
`├─ logs` - logs of services  
`│  ├─ cron` - CRON logs  
`│  ├─ msmtp` - MSMTP logs  
`│  ├─ mysql` - MySQL logs  
`│  ├─ nginx` - nginx and web hosts logs  
`│  ├─ php` - PHP logs  
`│  ├─ redis` - Redis logs  
`│  └─ supervisord` - supervisord logs  
`├─ tools` - scripts (mostly Bash)  
`│  ├─ scripts` - scripts libraries  
`│  │  ├─ detect_wsl.sh` - library for detecting execution under WSL  
`│  │  ├─ parse_env.sh` - library for parsing `.env` file  
`│  │  └─ statuses.sh` - library for pretty status messages in console  
`│  ├─ wsl` - Batch scripts for Windows  
`│  │  ├─ make_cert.bat` - making SSL certificates for domain  
`│  │  └─ mkcert_install.bat` - mkcert installation for making SSL certificates  
`│  ├─ composer.sh` - Composer command  
`│  ├─ cron_example.sh` - creating CRON job example  
`│  ├─ host_add.sh` - adding host  
`│  ├─ host_del.sh` - deleting host  
`│  ├─ init.sh` - initialization workspace script  
`│  ├─ make_cert.sh` - making SSL certificates for domain  
`│  ├─ mongo_export.sh` - export MongoDB to dump  
`│  ├─ mongo_import.sh` - import MongoDB from dump  
`│  ├─ mysql_export.sh` - export MySQL to dump  
`│  ├─ mysql_import.sh` - import MySQL from dump  
`│  └─ npm.sh` - NPM command  
`├─ www` - hosts sources directory  
`│  ├─ apcu` - APCu host  
`│  ├─ opcache-gui` - opcache-gui host  
`│  └─ phpmemadmin` - phpMemAdmin host  
`├─ .env` - environment variables file  
`├─ docker-compose.yml` - Docker Compose config  
`├─ hosts - Linux.lnk` - link to file [`hosts`](<./hosts - Linux.lnk>) on Linux OS  
`├─ hosts - Windows.lnk` - link to file [`hosts`](<./hosts - Windows.lnk>) on Windows OS  
`├─ LICENSE.txt` - license agreement  
`└─ README.md` - this ReadMe  



## Helpful

### Workspace Run in the Background
Execute `docker-compose up -d`

### Workspace Stopping
Execute `docker-compose stop`

### Typical Usage Example
Execute sequentially:
1. `docker-compose up -d`
2. `./tools/host_add.sh example.loc`
3. `cd www`
4. `../tools/composer.sh create-project laravel/laravel example`
5. `cd example`
6. `../../tools/npm.sh install`
7. `../../tools/npm.sh install vue`
8. `docker-compose run --rm php bash`
9. `cd example`
10. `git init`
11. `exit`
12. `docker-compose stop`

### Performance Enhancement
To enhance the performance of the working environment, comment out services that are not currently in use in the
[docker-compose.yml](docker-compose.yml) file.

### Setup xDebug for PhpStorm
Please read the [article](https://www.jetbrains.com/help/phpstorm/configuring-xdebug.html#configuring-xdebug-docker)
on the JetBrains website.

1. _File_ -> _Settings_ -> _Languages & Frameworks_ -> _PHP_ -> _Servers_  
  Add a new server with a name, which you set in `.env` at `XDEBUG_SERVERNAME` variable
    * set _Host_: **\_**
    * set _Debugger_: **Xdebug**
    * check **Use path mappings (select if the server is remote or symlinks are used)**
    * set mapping: a local directory **www** to **/var/www**

2. _File_ -> _Settings_ -> _Languages & Frameworks_ -> _PHP_
    * -> _PHP language Level_: choose **7.4** or **8.0**
    * -> _CLI Interpreter_: add a new interpreter **From Docker, Vagrant, VM, WSL, Remote** with a meaningful name:
      * choose _Server_: select a previously created server
      * set _Configuration File(s)_: set the path to the file [`docker-compose.yml`](docker-compose.yml)
      * choose _Service_: **php**
      * set _PHP executable_: **php**

3. _File_ -> _Settings_ -> _Languages & Frameworks_ -> _PHP_ -> _Debug_
    * set _Debug Port_: **9003**
    * check **Can accept external connections**
    * check **Resolve breakpoints if it's not available on the current line (Xdebug 2.8+)**

4. Press **Start Listening for PHP Debug Connections** only after running Docker PHP service

#### For test PHP CLI xDebug
Set a breakpoint in the file `<filename>.php` and execute:  
`docker-compose exec php sh -c "php <filename>.php"`

### SSL certificates on WSL
Execute from Windows command line:
1. Execute once `mkcert_install.bat` in the WSL scripts directory `./tools/wsl`.
2. Execute for each HTTPS host `make_cert.bat <domain>` in the WSL scripts directory `./tools/wsl`.
3. Uncomment SSL certificate attaching in the host config file `./hosts/<domain>.conf`. For example:
```
server {
    ...
    listen 443 ssl;
    ...
    ssl_certificate /var/certs/example.loc-cert.pem;
    ssl_certificate_key /var/certs/example.loc-cert.key;
    ...
}
```
4. Restart nginx service of Docker Compose.