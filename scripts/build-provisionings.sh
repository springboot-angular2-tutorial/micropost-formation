#!/bin/sh

travis login --org --skip-completion-check --github-token ${GH_TOKEN}
token=$(travis token --org)
body=$(cat << EOS
{
  "request": {
    "branch":"${TRAVIS_BRANCH}"
  }
}
EOS
)
curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Travis-API-Version: 3" \
  -H "Authorization: token ${token}" \
  -d "${body}" \
  https://api.travis-ci.org/repo/springboot-angular2-tutorial%2Fmicropost-provisionings/requests
