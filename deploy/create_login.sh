#!/usr/bin/env bash

# test mail
# download swaks
#curl http://www.jetmore.org/john/code/swaks/files/swaks-20181104.0.tar.gz --output ./swaks-20181104.0.tar.gz

# get api token
if [[ -v CANVAS_SECRET_API_FILE ]]; then
        api_key=$(cat ${CANVAS_SECRET_API_FILE})
#        echo $api_key >&2
else 
	api_key='123'
#        echo $api_key >&2
fi

#URL="https://"${CANVAS_DOMAIN}"/api/v1/accounts/1/authentication_providers"
URL="http://localhost/api/v1/accounts/1/authentication_providers"

# Create SAML config
curl -s "$URL" \
     -F 'auth_type=saml' \
     -F 'position=1' \
     -F "idp_entity_id=${STACK_NETWORK_URL_IDP}/saml2/idp/metadata.php" \
     -F "log_in_url=${STACK_NETWORK_URL_IDP}/saml2/idp/SSOService.php" \
     -F "log_out_url=${STACK_NETWORK_URL_IDP}/saml2/idp/SingleLogoutService.php" \
     -F 'identifier_format=urn:oasis:names:tc:SAML:2.0:nameid-format:transient' \
     -F 'login_attribute=mail' \
     -F 'sig_alg=RSA-SHA256' \
     -F "certificate_fingerprint=${STACK_NETWORK_IDP_FINGERPRINT}" \
     -H "Authorization: Bearer $api_key"
