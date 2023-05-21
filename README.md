# nanit-permission-scheduler


scrap code
```

#JSON_ADD='{"allowed":{"sound_on_stream":true}}'
#JSON_REMOVE='{ "allowed": { "sound_on_stream": false	}}'

#curl --location --request PUT 'https://api.nanit.com/babies/1f24bbec/users/'$USER'/permissions' \
#--header 'x-tc-transform: tti-app' \
#--header 'Content-Type: application/json' \
#--header 'x-tc-transformVersion: 0.2' \
#--header 'nanit-api-version: 1' \
#--header "Authorization: Token $TOKEN" \
#--data "$JSON_ADD"
```