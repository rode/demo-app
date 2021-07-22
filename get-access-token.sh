#!/bin/sh

set -e

tokenUrl=$(jq -r '.tokenUrl' < /usr/oidc/credentials.json)
if [ -z "${tokenUrl}" ]; then
  exit 0
fi

clientId=$(cat /usr/oidc/credentials.json | jq -r '.clientId')
clientSecret=$(cat /usr/oidc/credentials.json | jq -r '.clientSecret')

response=$(curl --user ${clientId}:${clientSecret} -d "grant_type=client_credentials" ${tokenUrl})

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
