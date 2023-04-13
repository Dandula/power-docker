#!/bin/bash

# shellcheck disable=SC2034
DEFAULT_SERVICES=(Apache nginx PHP Node MySQL Mongo Memcached Redis RabbitMQ Schedule Elasticsearch Logstash Kibana \
Filebeat phpMyAdmin Adminer Mongo-Express phpRedisAdmin ElasticHQ LocalStack)
# shellcheck disable=SC2034
DEFAULT_SERVICES_NEED_WWW=(Apache nginx PHP Node Schedule)

# shellcheck source=../parse_env.sh
. "${SCRIPT_DIR}/scripts/parse_env.sh"

ENV_PATH="${WORKSPACE_DIR}/.env"

CUSTOM_SERVICES_STR=$(parse_env "CUSTOM_SERVICES" "${ENV_PATH}")
CUSTOM_SERVICES_NEED_WWW_STR=$(parse_env "CUSTOM_SERVICES_NEED_WWW" "${ENV_PATH}")

IFS=',' read -ra CUSTOM_SERVICES <<< "$CUSTOM_SERVICES_STR"
IFS=',' read -ra CUSTOM_SERVICES_NEED_WWW <<< "$CUSTOM_SERVICES_NEED_WWW_STR"

SERVICES=("${DEFAULT_SERVICES[@]}" "${CUSTOM_SERVICES[@]}")
SERVICES_NEED_WWW=("${DEFAULT_SERVICES_NEED_WWW[@]}" "${CUSTOM_SERVICES_NEED_WWW[@]}")