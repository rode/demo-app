#!/bin/sh

set -e

apk add --no-cache jq curl > /dev/null 2>&1

tokenUrl=$(jq -r '.tokenUrl' < /usr/oidc/credentials.json)
if [ -z "${tokenUrl}" ]; then
  exit 0
fi

clientId=$(jq -r '.clientId' < /usr/oidc/credentials.json)
clientSecret=$(jq -r '.clientSecret' < /usr/oidc/credentials.json)

response=$(curl --user ${clientId}:${clientSecret} -k -d "grant_type=client_credentials" ${tokenUrl})

if [ "$(echo "$response" | jq 'has("error")')" == 'true' ]; then
  echo "Error retrieving token: ${response}"
  exit 1
fi

token=$(echo "${response}" | jq -r '.access_token | values')

if [ -z "${token}" ]; then
  echo "Response does not contain access token"
  exit 1;
fi

echo ${token}
