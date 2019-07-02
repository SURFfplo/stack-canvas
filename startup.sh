#!/bin/bash

#CANVAS_LMS_ADMIN_EMAIL=ronald.ham@surfnet.nl
#CANVAS_DOMAIN=lms.dev.dlo.surf.nl
#DB_HOST=canvas-db
#DB_USERNAME=canvas
#DB_NAME=canvas
#CANVAS_SECRET_FILE= /var/run/secrets/canvas_secret

if [[ -v CANVAS_SECRET_FILE ]]; then
        key=$(cat ${CANVAS_SECRET_FILE})
        devkey=$(echo -n "docker-canvas" | openssl sha1 -hmac $key)
        echo $devkey >&2
else 
	devkey='123'
        echo $devkey >&2
fi

#key='$(< "${!CANVAS_SECRET_FILE}")'
#devkey=echo -n "docker-canvas" | openssl sha1 -hmac $key

psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "INSERT INTO developer_keys (api_key, email, name, redirect_uri) VALUES ('general_developer_key', 'ronald.ham@surfnet.nl', 'Canvas API 4 $CANVAS_DOMAIN', '$CANVAS_DOMAIN');"

# 'crypted_token' value is hmac sha1 of 'canvas-docker' using default config/security.yml encryption_key value as secret
psql -U $DB_USERNAME -d $DB_NAME -h $DB_HOST -c "INSERT INTO access_tokens (created_at, crypted_token, developer_key_id, purpose, token_hint, updated_at, user_id) SELECT now(), $devkey, dk.id, 'general_developer_key', '', now(), 1 FROM developer_keys dk where dk.email = 'ronald.ham@surfnet.nl';"
