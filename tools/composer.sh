#!/bin/bash

mkdir -p .composer

docker run --rm -it \
  -v "${PWD}:/app" \
  -u "${UID}:$(id -g)" \
  composer "$@" --ignore-platform-reqs