#!/bin/sh

echo "teset"

travis login --org --github-token ${GH_TOKEN}
token=$(travis token --org)
body='{
"request": {
  "branch":"master"
}}'

curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Travis-API-Version: 3" \
  -H "Authorization: token ${token}" \
  -d "${body}" \
  https://api.travis-ci.org/repo/springboot-angular2-tutorial%2Fmicropost-provisionings/requests

echo "curl status $?"
