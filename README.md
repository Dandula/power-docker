# PowerDocker Guide
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/Dandula/power-docker)](https://github.com/Dandula/power-docker/releases/latest)
[![GitHub](https://img.shields.io/github/license/dandula/power-docker)](LICENSE.txt)

![Logo](assets/yoda.jpg "Portrait of the Jedi Master Yoda, from Star Wars")  
_Image: Bea.miau on [Wikimedia Commons](https://commons.wikimedia.org)_
> **"Do or do not. There is no try."**

*Read this in other languages: [English](README.md), [Русский](README.ru.md)*

## Contents
1. [About PowerDocker](#about-powerdocker)
2. [Downloading & Installation](#downloading--installation)
    1. [Downloading via GIT](#downloading-via-git)
    2. [Downloading via Wget](#downloading-via-wget)
    3. [Downloading via cURL](#downloading-via-curl)
    4. [Installation](#installation)
3. [Available Services](#available-services)
4. [Yoda](#yoda)
   1. [Yoda Help](#yoda-help)
5. [CLI Tools](#cli-tools)
6. [WEB Tools](#web-tools)
7. [File Structure](#file-structure)
8. [Helpful](#helpful)
    1. [Workspace Run in the Background](#workspace-run-in-the-background)
    2. [Workspace Stopping](#workspace-stopping)
    3. [Workspace Starting After Stopping](#workspace-starting-after-stopping)
    4. [Typical Usage Example](#typical-usage-example)
    5. [Adding a New Service](#adding-a-new-service)
    6. [Multiple Versions of PHP](#multiple-versions-of-php)
    7. [Setup xDebug for PhpStorm](#setup-xdebug-for-phpstorm)
        - [For test PHP CLI xDebug](#for-test-php-cli-xdebug)
    8. [SSL certificates on WSL](#ssl-certificates-on-wsl)



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
https://www.docker.com/products/docker-desktop
and Docker Compose:
https://docs.docker.com/compose/.

### Downloading via GIT
Execute: `git clone https://github.com/Dandula/power-docker.git`

### Downloading via Wget
Execute: `wget -c https://github.com/Dandula/power-docker/archive/main.tar.gz -O - | tar -xz`

### Downloading via cURL
Execute: `curl -sL https://github.com/Dandula/power-docker/archive/main.tar.gz | tar -xz`

### Installation
Execute: `cd power-docker && chmod +x ./tools/init.sh && ./tools/init.sh`



## Available Services
1. Apache
2. nginx
3. PHP (v7.4/8.0) with MSMTP as an MTA (for `mail()`). Also has Midnight Commander, Wget, cURL, GIT, Composer, npm.
4. Node
5. MySQL (v5.7)
6. MongoDB
7. Memcached
8. Redis
9. RabbitMQ & Management Plugin
10. Schedule: supervisor or PM2 & CRON
11. Elasticsearch 
12. Logstash
13. Kibana
14. Filebeat
15. Blackfire
16. phpMyAdmin
17. Adminer
18. Mongo-Express
19. phpRedisAdmin
20. ElasticHQ
21. LocalStack (local AWS)



## Yoda
After installing PowerDocker, you can use the `yoda` command, which allows you to access all of PowerDocker's features
through one general command.

The features available from the command line can be found in the [CLI Tools](#cli-tools) section.

For a list of available commands with descriptions, you can execute `yoda help`.

Note that in case the command `yoda <command>` is not recognized, it will be interpreted as `yoda dc <command>`.

Note that in case you cannot set an alias for the `yoda` command during workspace installation, you can execute it as
follows: `<path_to_tools>/yoda.sh <command>`.

### Yoda Help
```
PowerDocker Commands List:
init                 - workspace initialization
  [--clean-install]  - clean workspace initialization
help                 - this help
setup                - configure a set of services
dc <command>         - 'docker compose <command>' redirect
composer <command>   - 'composer <command>' redirect
npm <command>        - 'npm <command>' redirect
host:               
  add <domain> <dir> - add a new host
  del <domain>       - delete the host
  pub <domain>       - give access to the host from the Internet via ngrok
mount:              
  www                - mount WWW directories defined at hosts.map file
make:               
  ssh <file> <email> - make SSH certificate for SSH agent
  ssl                - make SSL certificate for a domain
mysql:              
  export <db>        - export MySQL database dump
  import <dump>      - import MySQL database dump
mongo:              
  export <db>        - export Mongo database dump
  import <dump>      - import Mongo database dump
redis:              
  export             - export Redis database dump
  import <dump>      - import Redis database dump
cron:               
  example            - add CRON job example
python <command>     - run Python command
pip <command>        - run pip command
poetry <command>     - run Poetry command
aws <command>        - LocalStack AWS-CLI command
```



## CLI Tools
1. [**yoda.sh**](./tools/yoda.sh) - common command interface for other tools  
   _Example:_ execute `./tools/yoda.sh <command>` for executing desired command of `yoda`.  
   **Important!** You can use the short reference `yoda`, instead of `./tools/yoda.sh` if the alias for it was set
   during the installation of the workspace!
2. [**help.sh**](./tools/help.sh) - help about `yoda`  
   _Example:_ execute `./tools/help.sh` for a help about `yoda`.
3. [**init.sh**](./tools/init.sh) - initializing the workspace  
   _Example:_ execute `./tools/init.sh [--clean-install]` for the initial setup.  
   **Important!** Option `--clean-install` overwrite config and not delete user data!
4. [**setup.sh**](./tools/setup.sh) - configure a set of services  
   _Example:_ execute `./tools/setup.sh` for form a set of services.  
   **Important!** This command stops all currently running services and remove their containers!
5. [**dc.sh**](./tools/dc.sh) - executes Docker Compose commands  
   _Example:_ execute `./tools/dc.sh run --rm php bash` for entering to container.  
   **Important!** Try to use docker compose through this tool.
6. [**mount_www.sh**](./tools/mount_www.sh) - create a Docker Compose setup for mounting host directories  
   _Example:_ execute `./tools/mount_www.sh` to form a Docker Compose setup.  
   **Important!** The formation of the setup is based on the file `hosts.map`.
7. [**host_add.sh**](./tools/host_add.sh) - add a new host  
   _Example:_ execute `<path_to_tools>/host_add.sh example.loc`.
8. [**host_del.sh**](./tools/host_del.sh) - delete the host  
   _Example:_ execute `<path_to_tools>/host_del.sh example.loc`.  
   **Important!** This command does not delete the directory with the sources of the host!
9. [**host_pub.sh**](./tools/host_pub.sh) - give access to the host from the Internet via ngrok  
   _Example:_ execute `<path_to_tools>/host_pub.sh example.loc`.
10. [**composer.sh**](./tools/init.sh) - Composer command  
    _Example:_ execute `../../tools/composer.sh composer require <package>` in the project directory `./www/<project>`.
11. [**npm.sh**](./tools/npm.sh) - NPM command  
    _Example:_ execute `../../tools/npm.sh install --save-dev <package>` in the project directory `./www/<project>`.
12. [**python.sh**](./tools/python.sh) - Python / pip / Poetry command  
    _Example:_ execute `../../tools/python.sh poetry init` in the project directory `./www/<project>`.
13. [**aws.sh**](./tools/aws.sh) - AWS CLI (local) command  
    _Example:_ execute `../../tools/aws.sh s3api create-bucket --bucket my-bucket --region us-east-1`.
14. [**mysql_export.sh**](./tools/mysql_export.sh) - export MySQL database dump to the directory `./data/dumps/mysql`  
    _Example:_ execute `<path_to_tools>/mysql_export.sh <database>` in any directory while the workspace is running.
15. [**mysql_import.sh**](./tools/mysql_import.sh) - import MySQL database dump from the directory `./data/dumps/mysql`  
   _Example:_ execute `<path_to_tools>/mysql_import.sh <dump_filename>` in any directory while the workspace is running.
16. [**mongo_export.sh**](./tools/mongo_export.sh) - export Mongo database dump to the directory `./data/dumps/mongo`  
    _Example:_ execute `<path_to_tools>/mongo_export.sh <database>` in any directory while the workspace is running.
17. [**mongo_import.sh**](./tools/mongo_import.sh) - import Mongo database dump from the directory `./data/dumps/mongo`  
    _Example:_ execute `<path_to_tools>/mongo_import.sh <dump_filename>` in any directory while the workspace is running.
18. [**redis_export.sh**](./tools/redis_export.sh) - export Redis database dump to the directory `./data/dumps/redis`  
    _Example:_ execute `<path_to_tools>/redis_export.sh` in any directory while the workspace is running.
19. [**redis_import.sh**](./tools/redis_import.sh) - import Redis database dump from the directory `./data/dumps/redis`  
    _Example:_ execute `<path_to_tools>/redis_import.sh <dump_filename>` in any directory while the workspace is running.
20. [**make_ssl_cert.sh**](./tools/make_ssl_cert.sh) - make SSL certificate for a domain and put to the directory `./data/certs/hosts`  
    _Example:_ execute `<path_to_tools>/make_ssl_cert.sh <domain>` in any directory.  
    **Important!** This command not compatible with WSL. Browser must be installed at the same host as used `mkcert`!
21. [**make_ssh_cert.sh**](./tools/make_ssh_cert.sh) - make SSH certificate for SSH agent of PHP service  
    _Example:_ execute `<path_to_tools>/make_ssh_cert.sh <cert_filename> <comment_email>` in any directory.  
    **Important!** You must run a new php container to apply the generated SSH agent key!
22. [**cron_example.sh**](./tools/cron_example.sh) - add CRON job example to the directory `./data/cron`  
    _Example:_ execute `<path_to_tools>/cron_example.sh <example_filename>` in any directory.
23. [**wsl/hosts_link.bat**](./tools/wsl/hosts_link.bat) - link to hosts file for the Windows OS  
    _Example:_ execute `<path_to_tools>\wsl\hosts_link.bat` in any directory.
24. [**wsl/mkcert_install.bat**](./tools/wsl/mkcert_install.bat) - install mkcert to the Windows OS  
    _Example:_ execute `<path_to_tools>\wsl\mkcert_install.bat` in any directory.
25. [**wsl/make_ssl_cert.bat**](./tools/wsl/make_ssl_cert.bat) - make SSL certificate for a domain from the Windows OS
    and put to the directory `./data/certs/hosts`  
    _Example:_ execute `<path_to_tools>\wsl\make_ssl_cert.bat <domain>` in any directory.



## WEB Tools
1. http://localhost:8081 - phpMyAdmin
2. http://localhost:8082 - Adminer
3. http://localhost:8083 - Mongo-Express
4. http://localhost:8084 - opcache-gui
5. http://localhost:8085 - APCu
6. http://localhost:8086 - phpMemAdmin
7. http://localhost:8087 - phpRedisAdmin
8. http://localhost:8088 - RabbitMQ Management
9. http://localhost:8089 - Kibana
10. http://localhost:8090 - ElasticHQ
11. http://localhost:8091 - LocalStack
12. http://localhost:8092 - ngrok web inspector



## File Structure
`├─ assets` - assets files  
`│  ├─ yoda.jpg` - logo image  
`│  └─ yoda.txt` - Yoda text art  
`├─ data` - user data stored between runs  
`│  ├─ cache` - cache directory  
`│  ├─ certs` - SSL & SSH certificates  
`│  │  ├─ ca` - bundle of CA root certificates  
`│  │  ├─ hosts` - SSL certificates for hosts  
`│  │  └─ mnt` - SSH certificates mounted to container of PHP service  
`│  ├─ cron` - configuration and scripts for running periodical jobs  
`│  │  └─ update_caroot` - CRON job for update of CA root certificates  
`│  ├─ databases` - databases files  
`│  ├─ dumps` - generated database dump files  
`│  ├─ localstack` - data of LocalStack services  
`│  └─ mails` - saved emails sent by [`fakesendmail`](./images/php/fakesendmail.sh)  
`├─ hosts` - hosts configs for the web servers  
`│  ├─ apache` - hosts configs for Apache  
`│  └─ nginx` - hosts configs for nginx  
`├─ images` - Dockerfiles and configs for services  
`│  ├─ apache` - Apache service config  
`│  │  └─ my-httpd.conf` - Apache config  
`│  ├─ filebeat` - конфиг сервиса Filebeat  
`│  │  └─ filebeat.yml` - Filebeat config  
`│  ├─ localstack` - LocalStack service config  
`│  │  ├─ config` - AWS CLI (local) config  
`│  │  └─ credentials` - AWS CLI (local) credentials  
`│  ├─ logstash` - Logstash service config  
`│  │  ├─ config` - Logstash configs  
`│  │  │  └─ pipelines.yml` - Logstash pipelines config  
`│  │  └─ pipeline` - Logstash pipelines  
`│  ├─ mysql` - MySQL service config  
`│  │  └─ my.cnf` - MySQL config  
`│  ├─ node` - Node service config  
`│  │  ├─ Dockerfile` - Dockerfile of Node service  
`│  │  └─ ecosystem.config.js` - PM2 config  
`│  ├─ php` - PHP service config  
`│  │  ├─ 7.4.Dockerfile` - Dockerfile of PHP v7.4 service  
`│  │  ├─ 8.0.Dockerfile` - Dockerfile of PHP v8.0 service  
`│  │  └─ blackfire.ini` - PHP config for Blackfire  
`│  │  ├─ fakesendmail.sh` - Bash script for saving emails instead of sending them _(copied into the image at build)_  
`│  │  ├─ msmtprc` - MSMTP config  
`│  │  ├─ php7.4.ini` - PHP v7.4 config  
`│  │  └─ php8.0.ini` - PHP v8.0 config  
`│  ├─ rabbitmq` - RabbitMQ service config  
`│  │  └─ rabbitmq.conf` - RabbitMQ config  
`│  ├─ redis` - Redis service config  
`│  │  └─ redis.conf` - Redis config  
`│  ├─ schedule` - Schedule service config: supervisor or PM2 and CRON jobs  
`│  │  ├─ additional.ini` - additional high-priority `php.ini` for CRON service  
`│  │  ├─ docker-entrypoint.sh` - Bash script for initialization CRON jobs and supervisor or PM2 _(copied into the image at build)_  
`│  │  ├─ Dockerfile` - Dockerfile of Schedule service  
`│  │  ├─ fakesendmail.sh` - Bash script for saving emails instead of sending them _(copied into the image at build)_  
`│  │  ├─ supervisord.conf` - supervisord config  
`│  ┴  └─ ecosystem.config.js` - PM2 config  
`├─ logs` - logs of services  
`│  ├─ apache` - Apache and web hosts logs  
`│  ├─ cron` - CRON logs  
`│  ├─ elasticsearch` - Elasticsearch logs  
`│  ├─ msmtp` - MSMTP logs  
`│  ├─ mysql` - MySQL logs  
`│  ├─ nginx` - nginx and web hosts logs  
`│  ├─ php` - PHP logs  
`│  ├─ redis` - Redis logs  
`│  └─ supervisord` - supervisord logs  
`├─ services` - setup for Docker Compose services  
`│  ├─ docker-compose.adminer.yml` - Adminer service setup  
`│  ├─ docker-compose.apache.yml` - Apache service setup  
`│  ├─ docker-compose.apache-volumes.yml` - volumes setup of Apache service  
`│  ├─ docker-compose.blackfire.yml` - Blackfire service setup  
`│  ├─ docker-compose.elastichq.yml` - ElasticHQ service setup  
`│  ├─ docker-compose.elasticsearch.yml` - Elasticsearch service setup  
`│  ├─ docker-compose.filebeat.yml` - Filebeat service setup  
`│  ├─ docker-compose.filebeat-volumes.yml` - volumes setup of Filebeat service  
`│  ├─ docker-compose.kibana.yml` - Kibana service setup  
`│  ├─ docker-compose.localstack.yml` - LocalStack service setup  
`│  ├─ docker-compose.logstash.yml` - Logstash service setup  
`│  ├─ docker-compose.logstash-volumes.yml` - volumes setup of Logstash service  
`│  ├─ docker-compose.memcached.yml` - Memcached service setup  
`│  ├─ docker-compose.mongo.yml` - Mongo service setup  
`│  ├─ docker-compose.mysql.yml` - MySQL service setup  
`│  ├─ docker-compose.nginx.yml` - nginx service setup  
`│  ├─ docker-compose.nginx-volumes.yml` - volumes setup of nginx service  
`│  ├─ docker-compose.node.yml` - Node service setup  
`│  ├─ docker-compose.node-volumes.yml` - volumes setup of Node service  
`│  ├─ docker-compose.php.yml` - PHP service setup  
`│  ├─ docker-compose.php-volumes.yml` - volumes setup of PHP service  
`│  ├─ docker-compose.phpmyadmin.yml` - phpMyAdmin service setup  
`│  ├─ docker-compose.phpredisadmin.yml` - phpRedisAdmin service setup  
`│  ├─ docker-compose.rabbitmq.yml` - RabbitMQ service setup  
`│  ├─ docker-compose.redis.yml` - Redis service setup  
`│  ├─ docker-compose.schedule.yml` - Schedule service setup  
`│  ├─ docker-compose.schedule-volumes.yml` - volumes setup of Schedule service  
`│  └─ docker-compose.yml` - general setup of Docker Compose services  
`├─ tools` - scripts (mostly Bash)  
`│  ├─ constants` - determining constants  
`│  │  ├─ colors.sh` - color codes  
`│  │  └─ services.sh` - array of workspace services  
`│  ├─ scripts` - scripts libraries  
`│  │  ├─ arr_process.sh` - library for arrays handling  
`│  │  ├─ detect_wsl.sh` - library for detecting execution under WSL  
`│  │  ├─ parse_env.sh` - library for parsing `.env` file  
`│  │  ├─ statuses.sh` - library for pretty status messages in console  
`│  │  └─ str_process.sh` - library for strings handling  
`│  ├─ wsl` - Batch scripts for Windows  
`│  │  ├─ hosts_link.bat` - creating a link to the file `hosts`  
`│  │  ├─ make_cert.bat` - making SSL certificates for domain  
`│  │  └─ mkcert_install.bat` - mkcert installation for making SSL certificates  
`│  ├─ aws.sh` - AWS CLI (local) command  
`│  ├─ composer.sh` - Composer command  
`│  ├─ cron_example.sh` - creating CRON job example  
`│  ├─ dc.sh` - shell over Docker Compose  
`│  ├─ host_add.sh` - adding host  
`│  ├─ host_del.sh` - deleting host  
`│  ├─ host_pub.sh` - giving access to the host from the Internet via ngrok  
`│  ├─ init.sh` - initialization workspace script  
`│  ├─ make_cert.sh` - making SSL certificates for domain  
`│  ├─ mongo_export.sh` - export MongoDB to dump  
`│  ├─ mongo_import.sh` - import MongoDB from dump  
`│  ├─ mount_www.sh` - creating a Docker Compose setup for mounting host directories  
`│  ├─ mysql_export.sh` - export MySQL to dump  
`│  ├─ mysql_import.sh` - import MySQL from dump  
`│  ├─ npm.sh` - NPM command  
`│  ├─ python.sh` - Python / pip / Poetry command   
`│  ├─ redis_export.sh` - export Redis to dump   
`│  ├─ redis_import.sh` - import Redis from dump   
`│  ├─ setup.sh` - configuring a set of services  
`│  └─ yoda.sh` - entrypoint for other scripts  
`├─ www` - hosts sources directory  
`│  ├─ apcu` - APCu host  
`│  ├─ opcache-gui` - opcache-gui host  
`│  └─ phpmemadmin` - phpMemAdmin host  
`├─ .env` - environment variables file  
`├─ CHANGELOG.md` - changelog  
`├─ hosts.link` - link to file `hosts`  
`├─ hosts.map` - mapping hosts to real directories  
`├─ LICENSE.txt` - license agreement  
`├─ node-ports.map` - mapping hosts to the ports used by the Node service  
`├─ README.md` - ReadMe in English  
`└─ README.ru.md` - ReadMe in Russian



## Helpful

### Workspace Run in the Background
Execute `yoda dc up -d`

### Workspace Stopping
Execute `yoda dc stop`

### Workspace Starting After Stopping
Execute `yoda dc start`

### Typical Usage Example
Execute sequentially:
1. `yoda dc up -d`
2. `yoda host:add example.loc`
3. `cd www`
4. `yoda composer create-project laravel/laravel example`
5. `cd example`
6. `yoda npm install`
7. `yoda npm install vue`
8. `yoda aws s3api create-bucket --bucket my-bucket --region us-east-1`
9. `yoda dc run --rm php bash`
10. `cd example`
11. `echo '<?php echo "Hello World".PHP_EOL;' > test.php`
12. `blackfire run php test.php`
13. `git init`
14. `exit`
15. `yoda dc stop`

### Adding a New Service
To add a new service, you must:
1. List the new service in the `CUSTOM_SERVICES` variable in the `.env` file. The service name can be in any case.
   To separate it from other services, use a comma `,`.  
   If the service needs access to the WWW directories, also add the service name to the `CUSTOM_SERVICES_NEED_WWWW`
   variable.
2. Copy one of the Docker Compose service files to the `services` directory named `docker-compose.<service_name>.yml`.  
   The `<service_name>` is the name of the service in lowercase.  
   Describe the service using Docker Compose syntax. It is recommended to use the same name for the service that you
   used in the filename.  
   To interact with the rest of the PowerDocker services, set `network: workspace`.
3. Restart Docker Compose by executing the command: `yoda dc restart`.

### Multiple Versions of PHP
To use more than one version of PHP in your project at the same time, do the following:
1. Add a new service by following the instructions in [Adding a New Service](#adding-a-new-service) section.
   It is recommended to copy the Docker Compose service file from the `docker-compose.<php|schedule>.yml` file.
2. If needed, create a new PHP configuration (`php.ini`) file by copying the existing example file into the
   `images/<service>` folder of the desired service. Specify the desired name for the configuration file.
3. In the configuration of the copied service specify the desired Dockerfile explicitly.
4. In the `volumes` configuration of the copied service specify the configuration file (the one you have created
   in step 2 or the one you have already had).

### Setup xDebug for PhpStorm
Please read the [article](https://www.jetbrains.com/help/phpstorm/configuring-xdebug.html#configuring-xdebug-docker)
on the JetBrains website.

1. _File_ -> _Settings_ -> _Languages & Frameworks_ -> _PHP_ -> _Servers_  
  Add a new server with a name, which you set in `.env` at `XDEBUG_SERVERNAME` variable
    * set _Host_: **\_**
    * set _Debugger_: **Xdebug**
    * check **Use path mappings (select if the server is remote or symlinks are used)**
    * set mapping. For default host directory: a local directory **www** to **/var/www**

2. _File_ -> _Settings_ -> _Languages & Frameworks_ -> _PHP_
    * -> _PHP language Level_: choose **7.4** or **8.0**
    * -> _CLI Interpreter_: add a new interpreter **From Docker, Vagrant, VM, WSL, Remote** with a meaningful name:
      * choose _Server_: select a previously created server
      * set _Configuration File(s)_: set the path to the file `docker-compose.php.yml`
      * choose _Service_: **php**
      * set _PHP executable_: **php**

3. _File_ -> _Settings_ -> _Languages & Frameworks_ -> _PHP_ -> _Debug_
    * set _Debug Port_: **9003**
    * check **Can accept external connections**
    * check **Resolve breakpoints if it's not available on the current line (Xdebug 2.8+)**

4. Press **Start Listening for PHP Debug Connections** only after running Docker PHP service

#### For test PHP CLI xDebug
Set a breakpoint in the file `<filename>.php` and execute:  
`yoda dc exec php sh -c "php <filename>.php"`

### SSL Certificates on WSL
Execute from Windows command line:
1. Execute once `mkcert_install.bat` in the WSL scripts directory `./tools/wsl`.
2. Execute for each HTTPS host `make_cert.bat <domain>` in the WSL scripts directory `./tools/wsl`.
3. Uncomment SSL certificate attaching in the host config file `./hosts/<domain>.conf`. For example:
* Apache:
```apacheconf
<VirtualHost *:443>
    ...
    SSLEngine on
    SSLCertificateFile "/var/certs/example.loc-cert.pem"
    SSLCertificateKeyFile "/var/certs/example.loc-cert.key"
    ...
</VirtualHost>
```
* nginx:
```nginx
server {
    ...
    listen 443 ssl;
    ...
    ssl_certificate /var/certs/example.loc-cert.pem;
    ssl_certificate_key /var/certs/example.loc-cert.key;
    ...
}
```
4. Restart web server service (`Apache` or `nginx`) of Docker Compose.