module TwitterAuth
  class GenericUser < ActiveRecord::Base
    attr_protected :twitter_id, :remember_token, :remember_token_expires_at
    
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
      :profile_background_image_url,
      :profile_background_tile,
      :friends_count,
      :statuses_count,
      :followers_count,      
      :favourites_count,
      :time_zone,
      :utc_offset
    ]
    
    with_options :if => :utilize_default_validations do |v|
      v.validates_presence_of :login, :twitter_id
      v.validates_format_of :login, :with => /\A[a-z0-9_]+\z/i
      v.validates_length_of :login, :in => 1..15
      v.validates_uniqueness_of :login, :case_sensitive => false
      v.validates_uniqueness_of :twitter_id, :message => "ID has already been taken."
      v.validates_uniqueness_of :remember_token, :allow_blank => true
    end
    
    def self.table_name; 'users' end

    def self.new_from_twitter_hash(hash)
      raise ArgumentError, 'Invalid hash: must include screen_name.' unless hash.key?('screen_name')

      raise ArgumentError, 'Invalid hash: must include id.' unless hash.key?('id')

      user = User.new
      user.twitter_id = hash['id'].to_s
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

    def utilize_default_validations
      true
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
      
      save

      {:value => self.remember_token, :expires => self.remember_token_expires_at}
    end

    def forget_me
      self.remember_token = self.remember_token_expires_at = nil
      self.save
    end
  end
end
