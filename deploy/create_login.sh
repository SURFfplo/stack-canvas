#!/usr/bin/env bash

# test mail
# download swaks
#curl http://www.jetmore.org/john/code/swaks/files/swaks-20181104.0.tar.gz --output ./swaks-20181104.0.tar.gz

# get api token
if [[ -v CANVAS_SECRET_API_FILE ]]; then
        api_key=$(cat ${CANVAS_SECRET_API_FILE})
        echo $api_key >&2
else 
	api_key='123'
        echo $api_key >&2
fi

#URL="https://"${CANVAS_DOMAIN}"/api/v1/accounts/1/authentication_providers"
URL="http://localhost/api/v1/accounts/1/authentication_providers"

# Create SAML config
curl "$URL" \
     -F 'auth_type=saml' \
     -F 'idp_entity_id=https://idp.dev.dlo.surf.nl/saml2/idp/metadata.php' \
     -F 'log_in_url=https://idp.dev.dlo.surf.nl/saml2/idp/SSOService.php' \
     -F 'log_out_url=https://idp.dev.dlo.surf.nl/saml2/idp/SingleLogoutService.php' \
     -F 'identifier_format=urn:oasis:names:tc:SAML:2.0:nameid-format:transient' \
     -F 'login_attribute=mail'
     -F 'sig_alg=RSA-SHA256' \
     -F 'certificate_fingerprint=d9:bd:30:11:e7:1d:12:fa:92:e9:3f:95:d6:c4:24:b5:cd:d3:6f:af' \
     -H "Authorization: Bearer $api_key"