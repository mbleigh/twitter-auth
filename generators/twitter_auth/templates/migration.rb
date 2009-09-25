class TwitterAuthMigration < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :twitter_id
      t.string :login
<% if options[:oauth] -%>
      t.string :access_token
      t.string :access_secret
<% elsif options[:basic] -%>
      t.binary :crypted_password
      t.string :salt
<% end -%>

      t.string :remember_token
      t.datetime :remember_token_expires_at

      # This information is automatically kept
      # in-sync at each login of the user. You
      # may remove any/all of these columns.
      t.string :name
      t.string :location
      t.string :description
      t.string :profile_image_url
      t.string :url
      t.boolean :protected
      t.string :profile_background_color
      t.string :profile_sidebar_fill_color
      t.string :profile_link_color
      t.string :profile_sidebar_border_color
      t.string :profile_text_color
      t.string :profile_background_image_url
      t.boolean :profile_background_tile
      t.integer :friends_count
      t.integer :statuses_count
      t.integer :followers_count
      t.integer :favourites_count

      # Probably don't need both, but they're here.
      t.integer :utc_offset
      t.string :time_zone

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
