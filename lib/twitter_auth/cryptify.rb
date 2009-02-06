require 'openssl'
module TwitterAuth
  module Cryptify
    class Error < StandardError; end
    mattr_accessor :crypt_password
    @@crypt_password = '--TwitterAuth-!##@--2ef'
    
    def self.encrypt(data, salt)
      cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
      cipher.encrypt
      cipher.pkcs5_keyivgen(crypt_password, salt)
      encrypted_data = cipher.update(data)
      encrypted_data << cipher.final
    end

    def self.decrypt(encrypted_data, salt)
      cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
      cipher.decrypt
      cipher.pkcs5_keyivgen(crypt_password, salt)
      data = cipher.update(encrypted_data)
      data << cipher.final
    end
  
    def self.generate_salt
      [rand(2**64 - 1)].pack("Q")
    end
  end
end