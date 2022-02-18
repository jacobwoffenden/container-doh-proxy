#!/usr/bin/env sh

LISTEN_PORT="${LISTEN_PORT:-53}"

dig @127.0.0.1 -p ${LISTEN_PORT} cloudflarestatus.com || exit 1