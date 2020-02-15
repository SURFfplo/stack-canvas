require "openssl"
secret_file=ENV["CANVAS_SECRET_FILE"]
api_key_file=ENV["CANVAS_API_KEY_FILE"]
secret = File.read(secret_file)
api_key = File.read(api_key_file)
outputval=OpenSSL::HMAC.hexdigest( OpenSSL::Digest.new('sha1'), secret, api_key)
$stdout.write outputval
