#!/bin/sh

set -x

TMP_FILENAME=/tmp/yourfilehere

cat << EOF > $TMP_FILENAME
image:
  tag: 577ed638721a7425474c6080b892ceefd109d3516124b965150abe5e4eacb5e8
EOF

ENCODED_CONTENTS="$(base64 $TMP_FILENAME)"
ENCODED_CONTENTS=$(printf '%s' $(cat $TMP_FILENAME) | base64 -w 0)
OAUTH_TOKEN="${GITHUB_PAT}""
SHA=$(curl -vvvvL \
  -X GET \
  -H "Authorization: token $OAUTH_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/rode/demo-app-deployment/contents/foo?ref=dev | jq .sha | sed 's/"//g')
echo "sha: $SHA"
curl -vvvvL \
  -X PUT \
  -H "Authorization: token $OAUTH_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/rode/demo-app-deployment/contents/foo \
  -d "{\"message\":\"message\",\"branch\":\"dev\",\"sha\":\"$SHA\",\"content\":\"$ENCODED_CONTENTS\"}"
