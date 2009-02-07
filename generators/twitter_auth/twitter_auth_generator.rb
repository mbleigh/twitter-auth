class TwitterAuthGenerator < Rails::Generator::Base 
  def manifest 
    record do |m| 
      m.class_collisions 'User'
      
      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => "twitter_auth_migration"
      m.template 'user.rb', File.join('app/models', 'user.rb')
    end
  end
end