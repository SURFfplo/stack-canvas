#!/bin/bash

#psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "delete from developer_keys;"
#psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "delete from access_tokens;"
#psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "delete from developer_key_account_bindings;"

# get key values 
api_key=$(cat $CANVAS_API_KEY_FILE)
secret=$(cat $CANVAS_SECRET_FILE)
developer_key=$(cat $CANVAS_DEV_KEY_FILE)

# create crpyted api key to be stored in canvas database
crypt=$(ruby ./config/create_crypted_token.rb)

#psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "INSERT INTO developer_keys (api_key, email, created_at, name, redirect_uri) VALUES ('$api_key' , 'ronald.ham@surfnet.nl', now(),  'Canvas API 4 $CANVAS_DOMAIN', '$CANVAS_DOMAIN');"
psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "INSERT INTO developer_keys (api_key, email, created_at, name, redirect_uri) VALUES ('$developer_key' , '$CANVAS_LMS_ADMIN_EMAIL', now(),  'Canvas API 4 $CANVAS_DOMAIN', 'https://$CANVAS_DOMAIN');"

# 'crypted_token' value is hmac sha1 of 'canvas-docker' using default config/security.yml encryption_key value as secret
psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "INSERT INTO access_tokens (created_at, crypted_token, developer_key_id, purpose, token_hint, updated_at, user_id) SELECT now(), '$crypt', dk.id, 'general_developer_key', '', now(), 1 FROM developer_keys dk where dk.email = '$CANVAS_LMS_ADMIN_EMAIL';"

# first create binding
psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "INSERT INTO developer_key_account_bindings  (account_id, developer_key_id, workflow_state, created_at, updated_at) VALUES (2, (select id FROM developer_keys dk where dk.email = '$CANVAS_LMS_ADMIN_EMAIL'), 'off', now(), now());"

# need to activate the token 
psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "update developer_key_account_bindings set workflow_state = 'on' where account_id = 2 and developer_key_id = (select id FROM developer_keys dk where dk.email = '$CANVAS_LMS_ADMIN_EMAIL');"


#psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "SELECT * FROM access_tokens;"
#psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "SELECT * FROM developer_keys;"
#psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "SELECT * FROM developer_key_account_bindings;"

#info in canvas for creating key
#https://github.com/instructure/canvas-lms/blob/88fae607ae7c386912992062990a6c405d6d76ab/lib/canvas/security.rb
#https://github.com/instructure/canvas-lms/blob/a664cdb0b26bf9d4473c0204dba38fc73a34ece7/lib/canvas/security/services_jwt.rb

nohup /usr/src/entrypoint &>/dev/null &

# enable directory for tmp files and allow docker to write to it
mkdir /usr/src/app/tmp/files
chown docker:docker /usr/src/app/tmp/files

# run script to enable single signon through SAML
JSON_OUTPUT="empty"
while [[ ! "$JSON_OUTPUT" =~ ^\{.* ]]
do
    JSON_OUTPUT=$(./config/create_login.sh)
    echo $JSON_OUTPUT
    sleep 10
done
