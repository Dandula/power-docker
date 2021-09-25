#!/bin/bash

# shellcheck disable=SC2034
SERVICES=(Apache nginx PHP Node MySQL Mongo Memcached Redis RabbitMQ Schedule Elasticsearch phpMyAdmin Adminer Mongo-Express phpRedisAdmin Kibana ElasticHQ LocalStack)
SERVICES_NEED_WWW=(Apache nginx PHP Node Schedule)