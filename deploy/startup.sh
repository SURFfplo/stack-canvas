#!/bin/bash

#CANVAS_LMS_ADMIN_EMAIL=ronald.ham@surfnet.nl
#CANVAS_DOMAIN=lms.dev.dlo.surf.nl
#DB_HOST=canvas-db
#DB_USERNAME=canvas
#DB_NAME=canvas
#CANVAS_SECRET_FILE= /var/run/secrets/canvas_secret

if [[ -v CANVAS_SECRET_API_FILE ]]; then
        api_key=$(cat ${CANVAS_SECRET_API_FILE})
        echo $key >&2
else 
	api_key='123'
        echo $key >&2
fi


secret=$(grep -A1 'production:' ./config/security.yml | tail -n1); secret=${secret//*encryption_key: /}; echo "$secret"

#psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "delete from developer_keys;"
#psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "delete from access_tokens;"
#psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "delete from developer_key_account_bindings;"


#api_key=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
developer_api_key=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)

#api_key='$(< "${!CANVAS_SECRET_FILE}")'
#secret need script to read from secret.yml
#secret=facdd3a131ddd8988b14f6e4e01039c93cfa0160
#echo $api_key
#api_key=SJaVS9t31Y1wHjtvPjsskQ1ScrzP1iQNae6RASmBB9tTngIHSQitpOEfysBEtcxC

crypt=$(echo -n $api_key | openssl sha1 -hmac $secret -binary | xxd -p)
echo $crypt

psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "INSERT INTO developer_keys (api_key, email, created_at, name, redirect_uri) VALUES ('$developer_api_key' , 'ronald.ham@surfnet.nl', now(),  'Canvas API 4 $CANVAS_DOMAIN', '$CANVAS_DOMAIN');"

# 'crypted_token' value is hmac sha1 of 'canvas-docker' using default config/security.yml encryption_key value as secret
psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "INSERT INTO access_tokens (created_at, crypted_token, developer_key_id, purpose, token_hint, updated_at, user_id) SELECT now(), '$crypt', dk.id, 'general_developer_key', '', now(), 1 FROM developer_keys dk where dk.email = 'ronald.ham@surfnet.nl';"

sleep 10
# need to activate the token 
psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "update developer_key_account_bindings set workflow_state = 'on' where account_id = 2 and developer_key_id = (select id FROM developer_keys dk where dk.email = 'ronald.ham@surfnet.nl');"


#psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "SELECT * FROM access_tokens;"
#psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "SELECT * FROM developer_keys;"
#psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "SELECT * FROM developer_key_account_bindings;"



#info in canvas for creating key
#https://github.com/instructure/canvas-lms/blob/88fae607ae7c386912992062990a6c405d6d76ab/lib/canvas/security.rb
#https://github.com/instructure/canvas-lms/blob/a664cdb0b26bf9d4473c0204dba38fc73a34ece7/lib/canvas/security/services_jwt.rb

nohup /usr/src/entrypoint &>/dev/null &

while [[ "$JSON_OUTPUT" =~ ^{.* ]]
do
    JSON_OUTPUT=$(./config/create_login.sh)
    echo $JSON_OUTPUT
    sleep 10
done
