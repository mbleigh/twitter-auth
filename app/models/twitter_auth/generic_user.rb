module TwitterAuth
  class GenericUser < ActiveRecord::Base
    attr_protected :login, :remember_token, :remember_token_expires_at
    
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
      :time_zone,
      :utc_offset
    ]
    
    validates_presence_of :login
    validates_format_of :login, :with => /\A[a-z0-9_]+\z/i
    validates_length_of :login, :in => 1..15
    validates_uniqueness_of :login, :case_sensitive => false
    validates_uniqueness_of :remember_token, :allow_blank => true
    
    def self.table_name; 'users' end

    def self.new_from_twitter_hash(hash)
      raise ArgumentError, 'Invalid hash: must include screen_name.' unless hash.key?('screen_name')

      user = User.new
      user.login = hash['screen_name']

      TWITTER_ATTRIBUTES.each do |att|
        user.send("#{att}=", hash[att.to_s]) if user.respond_to?("#{att}=")
      end

      user
    end

    def self.from_remember_token(token)
      first(:conditions => ["remember_token = ? AND remember_token_expires_at > ?", token, Time.now])
    end
      
    def assign_twitter_attributes(hash)
      TWITTER_ATTRIBUTES.each do |att|
        send("#{att}=", hash[att.to_s]) if respond_to?("#{att}=")
      end
    end

    def update_twitter_attributes(hash)
      assign_twitter_attributes(hash)
      save
    end

    if TwitterAuth.oauth?
      include TwitterAuth::OauthUser
    else
      include TwitterAuth::BasicUser
    end

    def twitter
      if TwitterAuth.oauth?
        TwitterAuth::Dispatcher::Oauth.new(self)
      else
        TwitterAuth::Dispatcher::Basic.new(self)
      end
    end

    def remember_me
      return false unless respond_to?(:remember_token)

      self.remember_token = ActiveSupport::SecureRandom.hex(10)
      self.remember_token_expires_at = Time.now + TwitterAuth.remember_for.days
    end

    def forget_me
      self.remember_token = self.remember_token_expires_at = nil
      self.save
    end
  end
end
