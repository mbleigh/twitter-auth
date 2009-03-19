class TwitterAuthGenerator < Rails::Generator::Base
  default_options :oauth => true, :basic => false

  def manifest
    record do |m|
      m.class_collisions 'User'

      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => 'twitter_auth_migration'
      m.template 'user.rb', File.join('app','models','user.rb')
      m.template 'twitter_auth.yml', File.join('config','twitter_auth.yml')
    end
  end

  protected

  def banner
    "Usage: #{$0} twitter_auth"
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    
    opt.on('-O', '--oauth', 'Use the OAuth authentication strategy to connect to Twitter. (default)') { |v| 
      options[:oauth] = v
      options[:basic] = !v
    }

    opt.on('-B', '--basic', 'Use the HTTP Basic authentication strategy to connect to Twitter.') { |v| 
      options[:basic] = v
      options[:oauth] = !v
    }
  end
end
