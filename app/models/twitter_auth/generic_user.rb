require 'openssl'

module TwitterAuth
  class GenericUser < ActiveRecord::Base
    # These are the attributes that are automatically
    # sucked in from Twitter.
    TWITTER_ATTRIBUTES = [
      :name,
      :location,
      :description,
      :profile_image_url,
      :url,
      :protected,
      :profile_background_color,
      :profile_sidebar_fill_color,
      :profile_link_color,
      :profile_sidebar_border_color,
      :profile_text_color,
      :friends_count,
      :statuses_count,
      :followers_count,      
      :favourites_count,      
      :utc_offset
    ]
    
    def self.table_name; 'users' end
  
    def self.authenticate(login, password)
      Twitter::Base.new(login, password).verify_credentials
    
      user = User[login] || User.new(:login => login)
      rebuild!(user, login, password)
    
      return user.reload
    rescue Twitter::CantConnect
      return nil
    end
  
    # Regathers the Twitter user attributes so that
    # they are never out of date.
    def self.rebuild!(user, login, password)
      @client = Twitter::Base.new(login, password)
      twitter_user = @client.user(login)
    
      user.password = password
    
      TWITTER_ATTRIBUTES.each do |att|
        user[att] = twitter_user.send(att) if user.respond_to?("#{att}=")
      end
    
      user.save!
    end
  
    def self.[](login)
      User.find_by_login(login) || User.find_by_id(login)
    end
  
    def password=(new_password)
      self.salt = TwitterAuth::Cryptify.generate_salt
      self.crypted_password = TwitterAuth::Cryptify.encrypt(new_password, self.salt)
    end
  
    def password
      TwitterAuth::Cryptify.decrypt(self.crypted_password, self.salt)
    end
  
    def twitter_client
      @client ||= Twitter::Base.new(self.login, self.password)
    end
  
    def rebuild!
      User.rebuild(self, login, password)
    end
  end
end