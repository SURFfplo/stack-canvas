require "openssl"
require "json/jwt"
key = OpenSSL::PKey::RSA.generate(2048)
outputval = key.public_key.to_jwk(kid: Time.now.utc).to_json
$stdout.write outputval
