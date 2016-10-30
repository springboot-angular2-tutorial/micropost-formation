#!/usr/bin/env bash

if [ "${ENVIRONMENT}" = "prod" ]; then
  # reset current role if exists
  test ! -v AWS_SESSION_TOKEN && direnv reload
fi

exit 0
