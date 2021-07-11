#!/bin/bash

function to_uppercase() {
  echo "${1^^}"
}

function to_lowercase() {
  echo "${1,,}"
}

function to_snake_case() {
  echo "${1//-/_}"
}