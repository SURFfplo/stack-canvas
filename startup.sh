#!/bin/bash

key=echo /run/secret/canvas_secret
devkey=echo -n "docker-canvas" | openssl sha1 -hmac $key

psql -U $DB_USER -d $DB_NAME -h $DB_HOST -c "INSERT INTO developer_keys (api_key, email, name, redirect_uri) VALUES ('general_developer_key', 'ronald.ham@surfnet.nl', 'Canvas API 4 $CANVAS_DOMAIN', '$CANVAS_DOMAIN');"

# 'crypted_token' value is hmac sha1 of 'canvas-docker' using default config/security.yml encryption_key value as secret
psql -U $DB_USER -d $DB_NAME -h $DB_HOST -c "INSERT INTO access_tokens (created_at, crypted_token, developer_key_id, purpose, token_hint, updated_at, user_id) SELECT now(), $devkey, dk.id, 'general_developer_key', '', now(), 1 FROM developer_keys dk where dk.email = 'ronald.ham@surfnet.nl';"