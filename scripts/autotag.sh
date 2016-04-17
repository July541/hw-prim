#!/usr/bin/env bash

if [ "$_system_type" == "Darwin" ]; then
  sed () {
    gsed "$@"
  }
fi

_repo_name=$(basename `git rev-parse --show-toplevel`)

_version=$(
  cat $_repo_name.cabal | grep '^version:' | head | cut -d ':' -f 2 | xargs
)

_commit=$(git rev-parse --verify HEAD)

_release_data=$(cat <<EOF
{
  "tag_name": "v$_version",
  "target_commitish": "$_commit",
  "name": "v$_version",
  "body": "New release",
  "draft": false,
  "prerelease": false
}
EOF
)

curl -H "Authorization: token $GITHUB_TOKEN" \
  -X POST https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/releases \
  --data "$_release_data"
