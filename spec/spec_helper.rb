begin
  require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
rescue LoadError
  puts "You need to install rspec in your base app"
  exit
end

require File.dirname(__FILE__) + '/../app/models/twitter_auth/generic_user'

class TwitterAuth::GenericUser
  def self.table_name; 'twitter_auth_users' end
end

Object.send(:remove_const, :User)
class User < TwitterAuth::OauthUser

end

require 'remarkable'
require File.dirname(__FILE__) + '/fixtures/factories'
require File.dirname(__FILE__) + '/fixtures/fakeweb'
require File.dirname(__FILE__) + '/fixtures/twitter'

plugin_spec_dir = File.dirname(__FILE__)
ActiveRecord::Base.logger = Logger.new(plugin_spec_dir + "/debug.log")

load(File.dirname(__FILE__) + '/schema.rb')

def define_basic_user_class!
  Object.remove_const(:User)
  Object.class_eval <<-RUBY
    class User < TwitterAuth::BasicUser

    end
  RUBY
end

def stub_oauth!
  TwitterAuth.stub!(:config).and_return({
    'strategy' => 'oauth',
    'oauth_consumer_key' => 'testkey',
    'oauth_consumer_secret' => 'testsecret'
  })
end

def stub_basic!
  TwitterAuth.stub!(:config).and_return({
    'strategy' => 'basic',
    'encryption_key' => 'secretcode'
  })
end
