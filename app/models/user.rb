require 'openssl'

class User < ActiveRecord::Base
  def self.authenticate(login, password)
    if verified = Twitter::Client.new.authenticate?(login, password)
      user = User[login] || User.new(:login => login)
      rebuild!(user, login, password)
    end
    
    return verified ? user.reload : nil
  end
  
  # Regathers the Twitter user attributes so that
  # they are never out of date.
  def self.rebuild!(user, login, password)
    @client = Twitter::Client.new(:login => login, :password => password)
    twitter_user = @client.user(login)
    
    user.password = password
    
    (Twitter::User.attributes - [:id]).each do |att|
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
    @client ||= Twitter::Client.new(:login => self.id, :password => self.password)
  end
  
  def rebuild!
    User.rebuild(self, login, password)
  end
end