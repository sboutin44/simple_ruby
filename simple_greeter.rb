# encrypt_greeter.rb

require 'openssl'
require 'base64'

# AES encryption config
CIPHER_TYPE = 'aes-256-cbc'

# Ask for input
print "What's your name? "
name = gets.chomp

print "Enter a password to encrypt your name: "
password = STDIN.noecho(&:gets).chomp
puts

# Create cipher for encryption
cipher = OpenSSL::Cipher.new(CIPHER_TYPE)
cipher.encrypt
salt = OpenSSL::Random.random_bytes(8)
key_iv = OpenSSL::PKCS5.pbkdf2_hmac_sha1(password, salt, 2000, cipher.key_len + cipher.iv_len)
key = key_iv[0, cipher.key_len]
iv = key_iv[cipher.key_len, cipher.iv_len]
cipher.key = key
cipher.iv = iv

# Encrypt the name
encrypted = cipher.update(name) + cipher.final
encoded = Base64.strict_encode64("Salted__" + salt + encrypted)

puts "🔐 Encrypted name: #{encoded}"

# Decryption
decipher = OpenSSL::Cipher.new(CIPHER_TYPE)
decipher.decrypt
decoded = Base64.decode64(encoded)
salt2 = decoded[8, 8]
encrypted_data = decoded[16..-1]

key_iv2 = OpenSSL::PKCS5.pbkdf2_hmac_sha1(password, salt2, 2000, decipher.key_len + decipher.iv_len)
key2 = key_iv2[0, decipher.key_len]
iv2 = key_iv2[decipher.key_len, decipher.iv_len]
decipher.key = key2
decipher.iv = iv2

decrypted = decipher.update(encrypted_data) + decipher.final

puts "✅ Decrypted name: #{decrypted}"
puts "👋 Hello again, #{decrypted}! Your name has #{decrypted.length} characters."
