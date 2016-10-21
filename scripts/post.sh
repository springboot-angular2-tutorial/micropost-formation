#!/usr/bin/env bash

if [ "${ENVIRONMENT}" = "prod" ]; then
  # reset current role if exists
  test ! -v AWS_SESSION_TOKEN && direnv reload
fi

# remove archived lambda functions
find  functions -mindepth 1 -maxdepth 1 -name "*.zip" | xargs rm -rf

exit 0
