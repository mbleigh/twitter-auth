require 'net/http'

module TwitterAuth
  module BasicUser
    def self.included(base)
      base.class_eval do
        attr_protected :crypted_password, :salt
      end

      base.extend TwitterAuth::BasicUser::ClassMethods
    end

    module ClassMethods
      def verify_credentials(login, password)
        response = TwitterAuth.net.start { |http|
          request = Net::HTTP::Get.new('/account/verify_credentials.json')
          request.basic_auth login, password
          http.request(request)
        }

        if response.code == '200'
          JSON.parse(response.body)
        else
          false
        end
      end

      def authenticate(login, password)
        if twitter_hash = verify_credentials(login, password)
          user = identify_or_create_from_twitter_hash_and_password(twitter_hash, password)
          user
        else
          nil
        end
      end

      def identify_or_create_from_twitter_hash_and_password(twitter_hash, password)
        if user = User.find_by_twitter_id(twitter_hash['id'].to_s)
          user.login = twitter_hash['screen_name']
          user.assign_twitter_attributes(twitter_hash)
          user.password = password
          user.save
          user
        else
          user = User.new_from_twitter_hash(twitter_hash)
          user.password = password
          user.save
          user
        end
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

