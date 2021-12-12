# Руководство по PowerDocker
[![GitHub-релиз (последний на текущую дату)](https://img.shields.io/github/v/release/Dandula/power-docker?label=%D1%80%D0%B5%D0%BB%D0%B8%D0%B7)](https://github.com/Dandula/power-docker/releases/latest)
[![GitHub](https://img.shields.io/github/license/dandula/power-docker?label=%D0%BB%D0%B8%D1%86%D0%B5%D0%BD%D0%B7%D0%B8%D1%8F)](LICENSE.txt)

![Логотип](assets/yoda.jpg "Портрет мастера-джедая Йоды, из Звездных войн")  
_Изображение: Bea.miau на [Wikimedia Commons](https://commons.wikimedia.org)_
> **"Делай или не делай. Не надо пытаться."**

*Читайте это на других языках: [English](README.md), [Русский](README.ru.md)*

## Содержание
1. [Про PowerDocker](#про-powerdocker)
2. [Загрузка и установка](#загрузка-и-установка)
    1. [Загрузка через GIT](#загрузка-через-git)
    2. [Загрузка через Wget](#загрузка-через-wget)
    3. [Загрузка через cURL](#загрузка-через-curl)
    4. [Установка](#установка)
3. [Доступные сервисы](#доступные-сервисы)
4. [Yoda](#yoda)
   1. [Справка по Yoda](#справка-по-yoda)
5. [Инструменты командной строки](#инструменты-командной-строки)
6. [WEB-инструменты](#web-инструменты)
7. [Файловая структура](#файловая-структура)
8. [Полезное](#полезное)
    1. [Запуск рабочего окружения в фоне](#запуск-рабочего-окружения-в-фоне)
    2. [Остановка рабочего окружения](#остановка-рабочего-окружения)
    3. [Запуск рабочего окружения после остановки](#запуск-рабочего-окружения-после-остановки)
    4. [Типовые примеры использования](#типовые-примеры-использования)
    5. [Добавление нового сервиса](#добавление-нового-сервиса)
    6. [Несколько версий PHP](#несколько-версий-php)
    7. [Настройка xDebug для PhpStorm](#настройка-xdebug-для-phpstorm)
        - [Для проверки PHP CLI xDebug](#для-проверки-php-cli-xdebug)
    8. [SSL-сертификаты на WSL](#ssl-сертификаты-на-wsl)



## Про PowerDocker
**PowerDocker** - рабочее окружение с использованием Docker для WEB-разработки.  

Основные принципы PowerDocker:
1. Ориентация в первую очередь на разработку PHP, а также Laravel
2. Самые необходимые расширения PHP из коробки
3. Доступность сервисов для основных задач разработки на Laravel
4. Легкий доступ к логам и настройкам
5. Автоматизация рутинных процессов с помощью стандартных инструментов Linux
6. Максимальное использование официальных образов из Docker Hub
7. Минимальный набор необходимого ПО на хосте



## Загрузка и установка
У вас должны быть обязательно установлены Wget и tar, и в зависимости от того, как какой способ установки вы выбрали,
вам может потребоваться GIT или cURL для установки этого рабочего окружения:  
`sudo apt-get update && sudo apt-get install -y wget tar`  
или  
`sudo apt-get update && sudo apt-get install -y wget tar git`  
или  
`sudo apt-get update && sudo apt-get install -y wget tar curl`.

И, конечно же, у вас должен быть установлен Docker:
https://www.docker.com/products/docker-desktop
и Docker Compose:
https://docs.docker.com/compose/.

### Загрузка через GIT
Выполните: `git clone https://github.com/Dandula/power-docker.git`

### Загрузка через Wget
Выполните: `wget -c https://github.com/Dandula/power-docker/archive/main.tar.gz -O - | tar -xz`

### Загрузка через cURL
Выполните: `curl -sL https://github.com/Dandula/power-docker/archive/main.tar.gz | tar -xz`

### Установка
Выполните: `cd power-docker && chmod +x ./tools/init.sh && ./tools/init.sh`



## Доступные сервисы
1. Apache
2. nginx
3. PHP (v7.4/8.0) с MSMTP в качестве MTA (для `mail()`). Также присутствует Midnight Commander, Wget, cURL, GIT,
   Composer, npm.
4. Node
5. MySQL (v5.7)
6. MongoDB
7. Memcached
8. Redis
9. RabbitMQ & Management Plugin
10. Schedule: supervisor или PM2 и CRON
11. Elasticsearch
12. phpMyAdmin
13. Adminer
14. Mongo-Express
15. phpRedisAdmin
16. Kibana
17. ElasticHQ
18. LocalStack (локальный AWS)



## Yoda
После установки PowerDocker вы можете использовать команду `yoda`, которая позволяет вам получить доступ ко всем
функциям PowerDocker при помощи одной общей команды.

Функции, доступные из командной строки, можно найти в разделе [Инструменты командной строки](#инструменты-командной-строки).

Чтобы получить список доступных команд с описаниями, вы можете выполнить `yoda help`.

Обратите внимание, что если команда `yoda <command>` не распознается, она будет интерпретирована как `yoda dc <command>`.

Обратите внимание: если у вас не получилось назначить алиас для команды `yoda` во время установки рабочего окружения,
вы можете выполнять ее следующим образом: `<path_to_tools>/yoda.sh <command>`.

### Справка по Yoda
```
PowerDocker Commands List:
init                 - workspace initialization
  [--clean-install]  - clean workspace initialization
help                 - this help
setup                - configure a set of services
dc <command>         - 'docker-compose <command>' redirect
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
cron:               
  example            - add CRON job example
python <command>     - run Python command
pip <command>        - run pip command
poetry <command>     - run Poetry command
aws <command>        - LocalStack AWS-CLI command
```



## Инструменты командной строки
1. [**yoda.sh**](./tools/yoda.sh) - общий командный интерфейс для других утилит  
   _Пример:_ выполните `./tools/yoda.sh <command>` для выполнения желаемой команды `yoda`.  
   **Важно!** Вы можете использовать краткую форму `yoda`, вместо `./tools/yoda.sh` если алиас для нее был задан при
   установке рабочего окружения!
2. [**help.sh**](./tools/help.sh) - справка про `yoda`  
   _Пример:_ выполните `./tools/help.sh` для справки про `yoda`.
3. [**init.sh**](./tools/init.sh) - инициализация рабочего окружения  
   _Пример:_ выполните `./tools/init.sh [--clean-install]` для начальной настройки.  
   **Важно!** Опция `--clean-install` перезаписывает конфиг, но не удаляет пользовательские данные!
4. [**setup.sh**](./tools/setup.sh) - настроить набор сервисов  
   _Пример:_ выполните `./tools/setup.sh` для формирования набора сервисов.  
   **Важно!** Эта команда останавливает все запущенные в данный момент сервисы и удаляет их контейнеры!
5. [**dc.sh**](./tools/dc.sh) - выполнить команду Docker Compose  
   _Пример:_ выполните `./tools/dc.sh run --rm php bash` для входа в контейнер.  
   **Важно!** Используйте docker-compose только через эту утилиту.
6. [**mount_www.sh**](./tools/mount_www.sh) - создать настройки Docker Compose для монтирования каталогов хостов  
   _Пример:_ выполните `./tools/mount_www.sh` чтобы сформировать настройки Docker Compose.  
   **Важно!** Формирование настроек основано на файле `hosts.map`.
7. [**host_add.sh**](./tools/host_add.sh) - добавить новый хост  
   _Пример:_ выполните `<path_to_tools>/host_add.sh example.loc`.
8. [**host_del.sh**](./tools/host_del.sh) - удалить хост  
   _Пример:_ выполните `<path_to_tools>/host_del.sh example.loc`.  
   **Важно!** Эта команда не удаляет каталог с исходными файлами хоста!
9. [**host_pub.sh**](./tools/host_pub.sh) - предоставление доступа к хосту из Интернета через ngrok  
   _Пример:_ выполните `<path_to_tools>/host_pub.sh example.loc`.
10. [**composer.sh**](./tools/init.sh) - команда Composer  
    _Пример:_ выполните `../../tools/composer.sh composer require <package>` в каталоге проекта `./www/<project>`.
11. [**npm.sh**](./tools/npm.sh) - команда NPM  
    _Пример:_ выполните `../../tools/npm.sh install --save-dev <package>` в каталоге проекта `./www/<project>`.
12. [**python.sh**](./tools/python.sh) - команда Python / pip / Poetry  
    _Пример:_ выполните `../../tools/python.sh poetry init` в каталоге проекта `./www/<project>`.
13. [**aws.sh**](./tools/aws.sh) - команда AWS CLI (локального)  
    _Пример:_ выполните `../../tools/aws.sh s3api create-bucket --bucket my-bucket --region us-east-1`.
14. [**mysql_export.sh**](./tools/mysql_export.sh) - экспортировать дамп базы данных MySQL в каталог `./data/dumps/mysql`  
    _Пример:_ выполните `<path_to_tools>/mysql_export.sh <database>` в любом каталоге, когда запущено рабочее окружение.
15. [**mysql_import.sh**](./tools/mysql_import.sh) - импортировать дамп базы данных MySQL из каталога `./data/dumps/mysql`  
   _Пример:_ выполните `<path_to_tools>/mysql_import.sh <dump_filename>` в любом каталоге, когда запущено рабочее окружение.
16. [**mongo_export.sh**](./tools/mongo_export.sh) - экспортировать дамп базы данных Mongo в каталог `./data/dumps/mongo`  
    _Пример:_ выполните `<path_to_tools>/mongo_export.sh <database>` в любом каталоге, когда запущено рабочее окружение.
17. [**mongo_import.sh**](./tools/mongo_import.sh) - импортировать дамп базы данных Mongo из каталога `./data/dumps/mongo`  
    _Пример:_ выполните `<path_to_tools>/mongo_import.sh <dump_filename>` в любом каталоге, когда запущено рабочее окружение.
18. [**make_ssl_cert.sh**](./tools/make_ssl_cert.sh) - сгенерировать SSL-сертификат для домена и положить в каталог `./data/certs/hosts`  
    _Пример:_ выполните `<path_to_tools>/make_ssl_cert.sh <domain>` в любом каталоге.  
    **Важно!** Эта команда не совместима с WSL. Браузер должен быть установлен на том же хосте, что и используемый `mkcert`!
19. [**make_ssh_cert.sh**](./tools/make_ssh_cert.sh) - сгенерировать SSH-сертификат для SSH-агента сервиса PHP  
    _Пример:_ выполните `<path_to_tools>/make_ssh_cert.sh <cert_filename> <comment_email>` в любом каталоге.  
    **Важно!** Вы должны запустить новый контейнер php, чтобы применился сгенерированный ключ SSH-агента!
20. [**cron_example.sh**](./tools/cron_example.sh) - добавить пример CRON-задания в каталог `./data/cron`  
    _Пример:_ выполните `<path_to_tools>/cron_example.sh <example_filename>` в любом каталоге.
21. [**wsl/hosts_link.bat**](./tools/wsl/hosts_link.bat) - создать ссылку на файл hosts для ОС Windows  
    _Пример:_ выполните `<path_to_tools>\wsl\hosts_link.bat` в любом каталоге.
22. [**wsl/mkcert_install.bat**](./tools/wsl/mkcert_install.bat) - установить mkcert в ОС Windows  
    _Пример:_ выполните `<path_to_tools>\wsl\mkcert_install.bat` в любом каталоге.
23. [**wsl/make_ssl_cert.bat**](./tools/wsl/make_ssl_cert.bat) - сгенерировать SSL-сертификат для домена из ОС Windows и
    положить в каталог `./data/certs/hosts`  
    _Пример:_ выполните `<path_to_tools>\wsl\make_ssl_cert.bat <domain>` в любом каталоге.



## WEB-инструменты
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
12. http://localhost:8092 - WEB-инспектор ngrok



## Файловая структура
`├─ assets` - файлы ресурсов  
`│  ├─ yoda.jpg` - изображение логотипа  
`│  └─ yoda.txt` - Йода в текстовой графике  
`├─ data` - пользовательские данные, хранящиеся между запусками  
`│  ├─ cache` - каталог кеша  
`│  ├─ certs` - сертификаты SSL и SSH  
`│  │  ├─ ca` - комплект корневых сертификатов ЦС  
`│  │  ├─ hosts` - SSL-сертификаты для хостов  
`│  │  └─ mnt` - SSH-сертификаты, монтируемые в контейнер сервиса PHP  
`│  ├─ cron` - конфигурация и скрипты для запуска периодических заданий  
`│  │  └─ update_caroot` - CRON-задание для обновления корневых сертификатов ЦС  
`│  ├─ databases` - файлы баз данных  
`│  ├─ dumps` - сгенерированные файлы дампов базы данных  
`│  ├─ localstack` - данные сервисов LocalStack  
`│  └─ mails` - сохраненные электронные письма, отправленные через [`fakesendmail`](./images/php/fakesendmail.sh)  
`├─ hosts` - конфиги хостов для WEB-серверов  
`│  ├─ apache` - конфиги хостов для Apache  
`│  └─ nginx` - конфиги хостов для nginx  
`├─ images` - dockerfiles и конфиги для сервисов  
`│  ├─ apache` - конфиг сервиса Apache  
`│  │  └─ my-httpd.conf` - Apache конфиг  
`│  ├─ localstack` - конфиг сервиса LocalStack  
`│  │  ├─ config` - конфиг AWS CLI (локального)  
`│  │  └─ credentials` - данные для входа AWS CLI (локального)  
`│  ├─ mysql` - конфиг сервиса MySQL  
`│  │  └─ my.cnf` - конфиг MySQL  
`│  ├─ node` - конфиг сервиса Node  
`│  │  ├─ Dockerfile` - Dockerfile сервиса Node  
`│  │  └─ ecosystem.config.js` - конфиг PM2  
`│  ├─ php` - конфиг сервиса PHP  
`│  │  ├─ 7.4.Dockerfile` - Dockerfile сервиса PHP версии 7.4  
`│  │  ├─ 8.0.Dockerfile` - Dockerfile сервиса PHP версии 8.0  
`│  │  ├─ fakesendmail.sh` - Bash-скрипт для сохранения emails вместо их отправки _(копируется в образ при сборке)_  
`│  │  ├─ msmtprc` - конфиг MSMTP  
`│  │  ├─ php7.4.ini` - конфиг PHP версии 7.4  
`│  │  └─ php8.0.ini` - конфиг PHP версии 8.0  
`│  ├─ rabbitmq` - конфиг сервиса RabbitMQ  
`│  │  └─ rabbitmq.conf` - конфиг RabbitMQ  
`│  ├─ redis` - конфиг сервиса Redis  
`│  │  └─ redis.conf` - конфиг Redis  
`│  ├─ schedule` - конфиг сервиса Schedule: supervisor или PM2 и CRON-задания  
`│  │  ├─ additional.ini` - дополнительный высокоприоритетный `php.ini` для службы CRON  
`│  │  ├─ docker-entrypoint.sh` - Bash-скрипт для инициализации CRON-заданий и supervisor или PM2 _(копируется в образ при сборке)_  
`│  │  ├─ Dockerfile` - Dockerfile сервиса Schedule  
`│  │  ├─ fakesendmail.sh` - Bash-скрипт для сохранения emails вместо их отправки _(копируется в образ при сборке)_  
`│  │  ├─ supervisord.conf` - конфиг supervisord  
`│  ┴  └─ ecosystem.config.js` - конфиг PM2  
`├─ logs` - логи сервисов  
`│  ├─ apache` - логи Apache и WEB-хостов  
`│  ├─ cron` - логи CRON  
`│  ├─ msmtp` - логи MSMTP  
`│  ├─ mysql` - логи MySQL  
`│  ├─ nginx` - логи nginx и WEB-хостов  
`│  ├─ php` - логи PHP  
`│  ├─ redis` - логи Redis  
`│  └─ supervisord` - логи supervisord  
`├─ services` - настройки сервисов Docker Compose  
`│  ├─ docker-compose.adminer.yml` - настройки сервиса Adminer  
`│  ├─ docker-compose.apache.yml` - настройки сервиса Apache  
`│  ├─ docker-compose.apache-volumes.yml` - настройки разделов сервиса Apache  
`│  ├─ docker-compose.elastichq.yml` - настройки сервиса ElasticHQ  
`│  ├─ docker-compose.elasticsearch.yml` - настройки сервиса Elasticsearch  
`│  ├─ docker-compose.kibana.yml` - настройки сервиса Kibana  
`│  ├─ docker-compose.localstack.yml` - настройки сервиса LocalStack  
`│  ├─ docker-compose.memcached.yml` - настройки сервиса Memcached  
`│  ├─ docker-compose.mongo.yml` - настройки сервиса Mongo  
`│  ├─ docker-compose.mysql.yml` - настройки сервиса MySQL  
`│  ├─ docker-compose.nginx.yml` - настройки сервиса nginx  
`│  ├─ docker-compose.nginx-volumes.yml` - настройки разделов сервиса nginx  
`│  ├─ docker-compose.node.yml` - настройки сервиса Node  
`│  ├─ docker-compose.node-volumes.yml` - настройки разделов сервиса Node  
`│  ├─ docker-compose.php.yml` - настройки сервиса PHP  
`│  ├─ docker-compose.php-volumes.yml` - настройки разделов сервиса PHP  
`│  ├─ docker-compose.phpmyadmin.yml` - настройки сервиса phpMyAdmin  
`│  ├─ docker-compose.phpredisadmin.yml` - настройки сервиса phpRedisAdmin  
`│  ├─ docker-compose.rabbitmq.yml` - настройки сервиса RabbitMQ  
`│  ├─ docker-compose.redis.yml` - настройки сервиса Redis  
`│  ├─ docker-compose.schedule.yml` - настройки сервиса Schedule  
`│  ├─ docker-compose.schedule-volumes.yml` - настройки разделов сервиса Schedule  
`│  └─ docker-compose.yml` - общая настройка сервисов Docker Compose  
`├─ tools` - скрипты (в основном Bash)  
`│  ├─ constants` - определение констант  
`│  │  ├─ colors.sh` - цветовые коды  
`│  │  └─ services.sh` - набор сервисов рабочего окружения  
`│  ├─ scripts` - библиотеки скриптов  
`│  │  ├─ arr_process.sh` - библиотека для работы с массивами  
`│  │  ├─ detect_wsl.sh` - библиотека для обнаружения выполнения под WSL  
`│  │  ├─ parse_env.sh` - библиотека для парсинга файла `.env`  
`│  │  ├─ statuses.sh` - библиотека для красивых сообщений о состоянии в консоли  
`│  │  └─ str_process.sh` - библиотека для работы со строками  
`│  ├─ wsl` - Batch-скрипты для Windows  
`│  │  ├─ hosts_link.bat` - создание ссылки на файл `hosts`  
`│  │  ├─ make_cert.bat` - создание SSL-сертификатов для домена  
`│  │  └─ mkcert_install.bat` - установка mkcert для создания SSL-сертификатов  
`│  ├─ aws.sh` - команда AWS CLI (локальный)  
`│  ├─ composer.sh` - команда Composer  
`│  ├─ cron_example.sh` - создание примера CRON-задания  
`│  ├─ dc.sh` - оболочка над Docker Compose  
`│  ├─ host_add.sh` - добавление хоста  
`│  ├─ host_del.sh` - удаление хоста  
`│  ├─ host_pub.sh` - предоставление доступа к хосту из Интернета через ngrok  
`│  ├─ init.sh` - скрипт инициализации рабочего окружения  
`│  ├─ make_cert.sh` - создание SSL-сертификатов для домена  
`│  ├─ mongo_export.sh` - экспортировать MongoDB в дамп  
`│  ├─ mongo_import.sh` - импортировать MongoDB из дампа  
`│  ├─ mount_www.sh` - создание настроек Docker Compose для монтирования каталогов хоста  
`│  ├─ mysql_export.sh` - экспортировать MySQL в дамп  
`│  ├─ mysql_import.sh` - импортировать MySQL из дампа  
`│  ├─ npm.sh` - команда NPM  
`│  ├─ python.sh` - команда Python / pip / Poetry   
`│  ├─ setup.sh` - настройка набора сервисов  
`│  └─ yoda.sh` - точка входа для других скриптов  
`├─ www` - каталог исходных файлов хостов  
`│  ├─ apcu` - хост APCu  
`│  ├─ opcache-gui` - хост opcache-gui  
`│  └─ phpmemadmin` - хост phpMemAdmin  
`├─ .env` - файл переменных среды  
`├─ CHANGELOG.md` - журнал изменений  
`├─ hosts.link` - ссылка на файл `hosts`  
`├─ hosts.map` - сопоставление хостов с реальными каталогами  
`├─ LICENSE.txt` - лицензионное соглашение  
`├─ node-ports.map` - сопоставление хостов с портами, используемыми сервисом Node  
`├─ README.md` - ReadMe на английском языке  
`└─ README.ru.md` - ReadMe на русском языке



## Полезное

### Запуск рабочего окружения в фоне
Выполните `yoda dc up -d`

### Остановка рабочего окружения
Выполните `yoda dc stop`

### Запуск рабочего окружения после остановки
Выполните `yoda dc start`

### Типовые примеры использования
Последовательность команд:
1. `yoda dc up -d`
2. `yoda host:add example.loc`
3. `cd www`
4. `yoda composer create-project laravel/laravel example`
5. `cd example`
6. `yoda npm install`
7. `yoda npm install vue`
7. `yoda aws s3api create-bucket --bucket my-bucket --region us-east-1`
8. `yoda dc run --rm php bash`
9. `cd example`
10. `git init`
11. `exit`
12. `yoda dc stop`

### Добавление нового сервиса
Чтобы добавить новый сервис, вам нужно:
1. Перечислить новую службу в переменной `CUSTOM_SERVICES` в файле` .env`. Название сервиса может быть в любом регистре.
   Чтобы отделить его от других сервисов, используйте запятую `,`.  
   Если службе требуется доступ к каталогам WWW, также добавьте имя службы в переменную `CUSTOM_SERVICES_NEED_WWWW`.
2. Скопируйте один из файлов сервисов Docker Compose в каталог `services` с именем `docker-compose.<service_name>.yml`.  
   `<service_name>` - это имя сервиса в нижнем регистре.  
   Опишите сервис, используя синтаксис Docker Compose. Рекомендуется использовать то же имя для сервиса, которое вы
   использовали в имени файла.  
   Для взаимодействия с остальными сервисами PowerDocker задайте `network: workspace`.
3. Перезапустите Docker Compose, выполнив команду: `yoda dc restart`.

### Несколько версий PHP
Чтобы использовать более одной версии PHP в вашем проекте одновременно, сделайте следующее:
1. Добавьте новый сервис, следуя инструкциям в разделе [Добавление нового сервиса](#добавление-нового-сервиса).
   Рекомендуется скопировать файл сервиса Docker Compose из файла `docker-compose.<php|schedule>.yml`.
2. При необходимости создайте новый файл конфигурации PHP (`php.ini`), скопировав существующий файл примера в папку
   `images/<service>` нужного сервиса. Укажите желаемое имя для файла конфигурации.
3. В конфиге копируемого сервиса явно укажите желаемый Dockerfile.
4. В настройках `volumes` скопированного сервиса укажите файл конфигурации (тот, который вы создали на шаге 2,
   или тот, который у вас уже был до этого).

### Настройка xDebug для PhpStorm
Пожалуйста, прочтите эту [статью](https://www.jetbrains.com/help/phpstorm/configuring-xdebug.html#configuring-xdebug-docker)
на сайте JetBrains.

1. _File_ -> _Settings_ -> _Languages & Frameworks_ -> _PHP_ -> _Servers_  
  Добавьте новый сервер с именем, которое вы задали в файле `.env` в переменной `XDEBUG_SERVERNAME`
    * задайте _Host_: **\_**
    * задайте _Debugger_: **Xdebug**
    * проверьте **Use path mappings (select if the server is remote or symlinks are used)**
    * настройте маппинг. Для каталога хостов по умолчанию: локальный каталог **www** на **/var/www**

2. _File_ -> _Settings_ -> _Languages & Frameworks_ -> _PHP_
    * -> _PHP language Level_: выберите **7.4** или **8.0**
    * -> _CLI Interpreter_: добавьте новый интерпретатор **From Docker, Vagrant, VM, WSL, Remote** с осмысленным именем:
      * выберите _Server_: выберите ранее созданный сервер
      * задайте _Configuration File(s)_: задайте путь к файлу `docker-compose.php.yml`
      * выберите _Service_: **php**
      * задайте _PHP executable_: **php**

3. _File_ -> _Settings_ -> _Languages & Frameworks_ -> _PHP_ -> _Debug_
    * задайте _Debug Port_: **9003**
    * проверьте **Can accept external connections**
    * проверьте **Resolve breakpoints if it's not available on the current line (Xdebug 2.8+)**

4. Нажмите **Start Listening for PHP Debug Connections** только после запуска сервиса Docker PHP

#### Для проверки PHP CLI xDebug
Поставьте точку останова в файле `<filename>.php` и выполните:  
`yoda dc exec php sh -c "php <filename>.php"`

### SSL-сертификаты на WSL
Выполните из командной строки Windows:
1. Выполните единожды `mkcert_install.bat`, находясь в каталоге скриптов WSL `./tools/wsl`.
2. Выполняйте для каждого HTTPS-хоста `make_cert.bat <domain>`, находясь в каталоге скриптов WSL `./tools/wsl`.
3. Раскомментируйте SSL-сертификаты, подключенные в конфиге хоста `./hosts/<domain>.conf`. Например:
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
4. Перезапустите Docker Compose сервис WEB-сервера (`Apache` или `nginx`).