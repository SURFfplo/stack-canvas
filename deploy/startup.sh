#!/bin/bash

#first get canvas up and running
/usr/src/entrypoint &
#wait for service to come up
sleep 40

#CANVAS_LMS_ADMIN_EMAIL=ronald.ham@surfnet.nl
#CANVAS_DOMAIN=lms.dev.dlo.surf.nl
#DB_HOST=canvas-db
#DB_USERNAME=canvas
#DB_NAME=canvas
#CANVAS_SECRET_FILE= /var/run/secrets/canvas_secret

#if [[ -v CANVAS_SECRET_API_FILE ]]; then
#        api_key=$(cat ${CANVAS_SECRET_API_FILE})
#        echo $key >&2
#else 
#	api_key='123'
#        echo $key >&2
#fi

#secret=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 40 | head -n 1)
#sed "s/12345/$secret/g" /usr/src/app/config/security.yml > /usr/src/app/config/sec_test.yml 
#cp /usr/src/app/config/sec_test.yml /usr/src/app/config/security.yml 
#rm ./config/sec_test.yml


#psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "delete from developer_keys;"
#psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "delete from access_tokens;"
#psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "delete from developer_key_account_bindings;"


#api_key=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
#developer_api_key=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
api_key=$(cat $CANVAS_API_KEY_FILE)
secret=$(cat $CANVAS_SECRET_FILE)

#api_key='$(< "${!CANVAS_SECRET_FILE}")'
#secret need script to read from secret.yml
#secret=facdd3a131ddd8988b14f6e4e01039c93cfa0160
#echo $api_key
#api_key=SJaVS9t31Y1wHjtvPjsskQ1ScrzP1iQNae6RASmBB9tTngIHSQitpOEfysBEtcxC

crypt=$(ruby ./config/create_crypted_token.rb)
#crypt=$(echo -n $api_key | openssl sha1 -hmac $secret -binary | xxd -p)
echo $crypt

#psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "INSERT INTO developer_keys (api_key, email, created_at, name, redirect_uri) VALUES ('$developer_api_key' , 'ronald.ham@surfnet.nl', now(),  'Canvas API 4 $CANVAS_DOMAIN', '$CANVAS_DOMAIN');"

psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "INSERT INTO developer_keys (api_key, email, created_at, name, redirect_uri) VALUES ('$api_key' , 'ronald.ham@surfnet.nl', now(),  'Canvas API 4 $CANVAS_DOMAIN', 'https://$CANVAS_DOMAIN');"

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

mkdir /usr/src/app/tmp/files
chown docker:docker /usr/src/app/tmp/files

# tijdelijk uitzetten
#JSON_OUTPUT="empty"
#while [[ ! "$JSON_OUTPUT" =~ ^\{.* ]]
#do
#    JSON_OUTPUT=$(./config/create_login.sh)
#    echo $JSON_OUTPUT
#    sleep 10
#done
