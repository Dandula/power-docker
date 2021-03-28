#!/bin/bash

docker run --rm -it \
  -w "/usr/src/app" \
  -v "${PWD}:/usr/src/app" \
  -u "${UID}:$(id -g)" \
  node npm "$@"