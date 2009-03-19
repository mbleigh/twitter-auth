module TwitterAuth
  module BasicUser
    def self.included(base)
      base.class_eval do
        attr_protected :crypted_password, :salt
      end
    end
   
    def password=(new_password)
      encrypted = TwitterAuth::Cryptify.encrypt(new_password)
      self.crypted_password = encrypted[:encrypted_data]
      self.salt = encrypted[:salt]
    end

    def password
      TwitterAuth::Cryptify.decrypt(self.crypted_password, self.salt)
    end
  end
end

