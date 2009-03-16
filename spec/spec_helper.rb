begin
  require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
rescue LoadError
  puts "You need to install rspec in your base app"
  exit
end

require File.dirname(__FILE__) + '/fixtures/fakeweb'

plugin_spec_dir = File.dirname(__FILE__)
ActiveRecord::Base.logger = Logger.new(plugin_spec_dir + "/debug.log")

def stub_oauth!
  TwitterAuth.stub!(:config).and_return({
    'strategy' => 'oauth',
    'oauth_consumer_key' => 'testkey',
    'oauth_consumer_secret' => 'testsecret'
  })
end
