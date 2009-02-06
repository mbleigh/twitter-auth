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
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :users
  end
end
