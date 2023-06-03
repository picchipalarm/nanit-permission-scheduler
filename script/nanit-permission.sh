#!/bin/bash
set -e
set -u

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
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

sendEmail() {
  curl -s --output /dev/null \
    --header "Authorization: Basic $SEND_CLICK_TOKEN" \
    --request POST \
    --header "Content-Type: application/json" \
    --data-binary "{
       \"to\":[
          {
             \"email\":\"$EMAIL\",
             \"name\":\"$EMAIL\"
          }
       ],
       \"from\":{
          \"email_address_id\":$EMAIL_ID,
          \"name\":\"nanit script error\"
       },
       \"subject\":\"nanit script error\",
       \"body\":\"$1\"
    }" \
    'https://rest.clicksend.com/v3/email/send'
    logd "email sent"
}


JSON='{ "refresh_token": "'$REFRESH_TOKEN'"}'

statusCode=$(curl -s --write-out '%{http_code}' -o "$TEMP_JSON_RESPONSE" \
  --location 'https://api.nanit.com/tokens/refresh' \
  --header 'Content-Type: application/json' \
  --header 'nanit-api-version: 1' \
  --data "$JSON")

logd "Status code from refresh: $statusCode"
if [[ $statusCode != 200 ]]; then
  sendEmail "refresh failed code $statusCode"
  exit 1
fi

NEW_REFRESH_TOKEN=$(cat "$TEMP_JSON_RESPONSE" | grep -o '"refresh_token":"[^"]*' | grep -o '[^"]*$')
sed -i.bak "/^REFRESH_TOKEN/s/=.*$/=$NEW_REFRESH_TOKEN/" "$SCRIPT_DIR/.env"

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
  sendEmail "permissions failed code $statusCode"
  exit 1
fi

rm "$TEMP_JSON_RESPONSE"

logd "Finished nanit permissions script"
