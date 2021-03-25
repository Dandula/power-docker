#!/bin/bash

function is_wsl() {
  if grep -qi "Microsoft" /proc/version; then
    echo 1
  else
    echo 0
  fi
}