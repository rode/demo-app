#!/bin/sh

set -x

TMP_FILENAME=/tmp/yourfilehere

cat << EOF > $TMP_FILENAME
image:
  tag: ${IMAGE_TAG}
EOF

ENCODED_CONTENTS="$(base64 $TMP_FILENAME | tr -d \\n)"
#ENCODED_CONTENTS=$(printf '%s' $(cat $TMP_FILENAME) | base64 -)
OAUTH_TOKEN="${GITHUB_PAT}"
SHA=$(curl -vvvvL \
  -X GET \
  -H "Authorization: token $OAUTH_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/rode/demo-app-deployment/contents/env-values.yaml?ref=dev | jq .sha | sed 's/"//g')
echo "sha: $SHA"
curl -vvvvL \
  -X PUT \
  -H "Authorization: token $OAUTH_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/rode/demo-app-deployment/contents/env-values.yaml \
  -d "{\"message\":\"Deployment to Dev from CI - ${GIT_COMMIT}\",\"branch\":\"dev\",\"sha\":\"$SHA\",\"content\":\"$ENCODED_CONTENTS\"}"
