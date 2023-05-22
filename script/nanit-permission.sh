#!/bin/bash
set -e
set -u

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$SCRIPT_DIR/.env"

if [ -z "$1" ]; then
  echo "No argument supplied"
  exit 1
fi
ENABLE_DISABLE=$1

logd() {
  if [[ $DEBUG = true ]]; then
    echo "$(date +%FT%X)" "$1" >>"$FIREWALLA_LOG_FILE"
  fi
}

logd "Starting nanit permissions script"

JSON='{ "refresh_token": "'$REFRESH_TOKEN'"}'

statusCode=$(curl -s --write-out '%{http_code}' -o "$TEMP_JSON_RESPONSE" \
  --location 'https://api.nanit.com/tokens/refresh' \
  --header 'Content-Type: application/json' \
  --header 'nanit-api-version: 1' \
  --data "$JSON")

logd "Status code from refresh: $statusCode"
if [[ $statusCode != 200 ]]; then
  exit 1
fi

TOKEN=$(cat "$TEMP_JSON_RESPONSE" | grep -o '"token":"[^"]*' | grep -o '[^"]*$')

statusCode=$(curl -s --write-out '%{http_code}' -o "$TEMP_JSON_RESPONSE" \
  --location --request PUT "https://api.nanit.com/babies/1f24bbec/users/$USER/permissions/$ENABLE_DISABLE" \
  --header 'x-tc-transform: tti-app' \
  --header 'Content-Type: application/json' \
  --header 'x-tc-transformVersion: 0.2' \
  --header 'nanit-api-version: 1' \
  --header "Authorization: Token $TOKEN" \
  --data '')

logd "Status code from permissions: $statusCode"
if [[ $statusCode != 200 ]]; then
  exit 1
fi

rm "$TEMP_JSON_RESPONSE"

logd "Finished nanit permissions script"
