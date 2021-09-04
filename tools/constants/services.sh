#!/bin/bash

# shellcheck disable=SC2034
SERVICES=(nginx PHP MySQL Mongo Memcached Redis RabbitMQ Schedule phpMyAdmin Adminer Mongo-Express phpRedisAdmin)
SERVICES_NEED_WWW=(nginx PHP Schedule)