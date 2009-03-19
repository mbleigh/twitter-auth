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

class User < TwitterAuth::GenericUser; end

require 'remarkable'
require File.dirname(__FILE__) + '/fixtures/factories'
require File.dirname(__FILE__) + '/fixtures/fakeweb'
require File.dirname(__FILE__) + '/fixtures/twitter'

plugin_spec_dir = File.dirname(__FILE__)
ActiveRecord::Base.logger = Logger.new(plugin_spec_dir + "/debug.log")

load(File.dirname(__FILE__) + '/schema.rb')

def define_basic_user_class!
  TwitterAuth::GenericUser.send :include, TwitterAuth::BasicUser 
end

def define_oauth_user_class!
  TwitterAuth::GenericUser.send :include, TwitterAuth::OauthUser  
end

def stub_oauth!
  TwitterAuth.stub!(:config).and_return({
    'strategy' => 'oauth',
    'oauth_consumer_key' => 'testkey',
    'oauth_consumer_secret' => 'testsecret'
  })
  define_oauth_user_class!
end

def stub_basic!
  TwitterAuth.stub!(:config).and_return({
    'strategy' => 'basic',
    'encryption_key' => 'secretcode'
  })
  define_basic_user_class!
end

define_oauth_user_class!
