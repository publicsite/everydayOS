#!/bin/sh

cd "$(dirname "$0")"

DOOBLE_HOME="${HOME}/.dooble-login" ./Dooble $@
