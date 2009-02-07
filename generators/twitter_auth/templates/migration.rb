class TwitterAuthMigration < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string   :login
      t.string   :crypted_password
      t.string   :salt
      
      # Basic info pulled automatically from Twitter. 
      # Feel free to remove any of these columns you don't want.
      t.string  :name
      t.string  :location
      t.text    :description
      t.string  :profile_image_url
      t.string  :url
      t.boolean :protected
      t.string  :profile_background_color
      t.string  :profile_sidebar_fill_color
      t.string  :profile_link_color
      t.string  :profile_sidebar_border_color
      t.string  :profile_text_color      
      t.integer :friends_count
      t.integer :statuses_count
      t.integer :followers_count      
      t.integer :favourites_count      
      t.integer :utc_offset
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :users
  end
end
