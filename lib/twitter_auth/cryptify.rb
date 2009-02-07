module TwitterAuth
  module Cryptify
    class Error < StandardError; end
    mattr_accessor :crypt_password
    @@crypt_password = '--TwitterAuth-!##@--2ef'
    
    def self.encrypt(data, salt)
      EzCrypto::Key.encrypt_with_password(crypt_password, salt, data)
    end

    def self.decrypt(encrypted_data, salt)
      EzCrypto::Key.decrypt_with_password(crypt_password, salt, encrypted_data)
    end
  
    def self.generate_salt
      ActiveSupport::SecureRandom.hex(4)
    end
  end
end