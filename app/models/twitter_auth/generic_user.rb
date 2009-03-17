module TwitterAuth
  class GenericUser < ActiveRecord::Base
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
    
    validates_presence_of :login
    validates_format_of :login, :with => /\A[a-z0-9_]+\z/
    validates_length_of :login, :in => 1..15
    validates_uniqueness_of :login
    
    def self.table_name; 'users' end

    def self.new_from_twitter_hash(hash)
      raise ArgumentError, 'Invalid hash: must include screen_name.' unless hash.key?('screen_name')

      user = User.new(:login => hash.delete('screen_name'))

      TWITTER_ATTRIBUTES.each do |att|
        user.send("#{att}=", hash[att.to_s]) if user.respond_to?("#{att}=")
      end

      user
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
  end
end
