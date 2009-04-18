require File.dirname(__FILE__) + '/spec_helper'

describe TwitterAuth do
  describe '.base_url' do
    it 'should have default to https://twitter.com' do
      TwitterAuth.stub!(:config).and_return({})
      TwitterAuth.base_url.should == 'https://twitter.com'
    end

    it 'should otherwise load from the config[base_url]' do
      TwitterAuth.stub!(:config).and_return({'base_url' => 'https://example.com'})
      TwitterAuth.base_url.should == 'https://example.com'
    end

    it 'should utilize oauth consumer settings' do
      @config = TwitterAuth.config
      TwitterAuth.stub!(:config).and_return(@config.merge('authorize_path' => '/somewhere_else'))
      TwitterAuth.consumer.authorize_path.should == '/somewhere_else'
    end
  end

  describe ".path_prefix" do
    it 'should be blank if the base url does not have a path' do
      TwitterAuth.stub!(:base_url).and_return("https://twitter.com:443")
      TwitterAuth.path_prefix.should == ""
    end

    it 'should return the path prefix if one exists' do
      TwitterAuth.stub!(:base_url).and_return("https://api.presentlyapp.com/api/twitter")
      TwitterAuth.path_prefix.should == "/api/twitter"
    end
  end

  describe '.api_timeout' do
    it 'should default to 10' do
      TwitterAuth.stub!(:config).and_return({})
      TwitterAuth.api_timeout.should == 10
    end

    it 'should be settable via config' do
      TwitterAuth.stub!(:config).and_return({'api_timeout' => 15})
      TwitterAuth.api_timeout.should == 15
    end
  end

  describe '.remember_for' do
    it 'should default to 14' do
      TwitterAuth.stub!(:config).and_return({})
      TwitterAuth.remember_for.should == 14
    end

    it 'should be settable via config' do
      TwitterAuth.stub!(:config).and_return({'remember_for' => '7'})
      TwitterAuth.remember_for.should == 7
    end
  end

  describe '.net' do
    before do
      stub_basic!
    end

    it 'should return a Net::HTTP object' do
      TwitterAuth.net.should be_a(Net::HTTP)
    end

    it 'should be SSL if the base_url is' do
      TwitterAuth.stub!(:config).and_return({'base_url' => 'http://twitter.com'})
      TwitterAuth.net.use_ssl?.should be_false
      TwitterAuth.stub!(:config).and_return({'base_url' => 'https://twitter.com'})
      TwitterAuth.net.use_ssl?.should be_true
    end

    it 'should work from the base_url' do
      @net = Net::HTTP.new('example.com',80)
      Net::HTTP.should_receive(:new).with('example.com',80).and_return(@net)
      TwitterAuth.stub!(:config).and_return({'base_url' => 'http://example.com'})
      TwitterAuth.net
    end
  end 

  describe '#config' do
    before do
      TwitterAuth.send(:instance_variable_set, :@config, nil)
      @config_file = File.open(File.dirname(__FILE__) + '/fixtures/config/twitter_auth.yml')
      File.should_receive(:open).any_number_of_times.and_return(@config_file) 
    end

    it 'should load a hash from RAILS_ROOT/config/twitter.yml' do
      TwitterAuth.config.should be_a(Hash)
    end

    it 'should be able to override the RAILS_ENV' do
      TwitterAuth.config('development')['oauth_consumer_key'].should == 'devkey'
    end
  end

  describe '#consumer' do
    before do
      stub_oauth!
    end

    it 'should be an OAuth Consumer' do
      TwitterAuth.consumer.should be_a(OAuth::Consumer)
    end

    it 'should use the credentials from #config' do
      TwitterAuth.consumer.key.should == 'testkey'
      TwitterAuth.consumer.secret.should == 'testsecret'
    end

    it 'should use the TwitterAuth base_url' do
      TwitterAuth.stub!(:base_url).and_return('https://example.com')
      TwitterAuth.consumer.site.should == TwitterAuth.base_url
      TwitterAuth.consumer.site.should == 'https://example.com'
    end
  end

  describe '#strategy' do
    it 'should pull and symbolize from the config' do
      TwitterAuth.stub!(:config).and_return({'strategy' => 'oauth'})
      TwitterAuth.strategy.should == TwitterAuth.config['strategy'].to_sym
    end
    
    it 'should raise an argument error if not oauth or basic' do
      TwitterAuth.stub!(:config).and_return({'strategy' => 'oauth'}) 
      lambda{TwitterAuth.strategy}.should_not raise_error(ArgumentError)

      TwitterAuth.stub!(:config).and_return({'strategy' => 'basic'}) 
      lambda{TwitterAuth.strategy}.should_not raise_error(ArgumentError)

      TwitterAuth.stub!(:config).and_return({'strategy' => 'invalid_strategy'}) 
      lambda{TwitterAuth.strategy}.should raise_error(ArgumentError)
    end
  end

  it '#oauth? should be true if strategy is :oauth' do
    TwitterAuth.stub!(:config).and_return({'strategy' => 'oauth'})
    TwitterAuth.oauth?.should be_true
    TwitterAuth.basic?.should be_false
  end

  it '#basic? should be true if strategy is :basic' do
    TwitterAuth.stub!(:config).and_return({'strategy' => 'basic'})
    TwitterAuth.oauth?.should be_false
    TwitterAuth.basic?.should be_true
  end

  describe '#encryption_key' do
    it 'should raise a Cryptify error if none is found' do
      TwitterAuth.stub!(:config).and_return({})
      lambda{TwitterAuth.encryption_key}.should raise_error(TwitterAuth::Cryptify::Error, "You must specify an encryption_key in config/twitter_auth.yml")
    end

    it 'should return the config[encryption_key] value' do
      TwitterAuth.stub!(:config).and_return({'encryption_key' => 'mickeymouse'})
      TwitterAuth.encryption_key.should == 'mickeymouse'
    end
  end
end
