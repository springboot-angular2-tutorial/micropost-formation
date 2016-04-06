#!/bin/sh

travis login --org --github-token ${GH_TOKEN}
echo 1
token=$(travis token --org)
echo 2
body=$(cat << EOS
{
  "request": {
    "branch":"${TRAVIS_BRANCH}"
  }
}
EOS
)
echo 3
curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Travis-API-Version: 3" \
  -H "Authorization: token ${token}" \
  -d "${body}" \
  https://api.travis-ci.org/repo/springboot-angular2-tutorial%2Fmicropost-provisionings/requests
echo 4
