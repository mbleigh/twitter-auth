require File.dirname(__FILE__) + '/spec_helper'

describe TwitterAuth do
  it 'should have a base_url that defaults to https://twitter.com' do
    TwitterAuth.base_url.should == 'https://twitter.com'
  end

  it 'should be able to set the base_url' do
    TwitterAuth.base_url = 'https://example.com'
    TwitterAuth.base_url.should == 'https://example.com'
  end

  describe '#config' do
    it 'should load a hash from RAILS_ROOT/config/twitter.yml' do
      RAILS_ROOT = File.dirname(__FILE__) + '/fixtures'
      TwitterAuth.config.should be_a(Hash)
      TwitterAuth.config['oauth_consumer_key'].should == 'testkey'
      TwitterAuth.config['oauth_consumer_secret'].should == 'testsecret'
    end

    it 'should be able to override the RAILS_ENV' do
      TwitterAuth.config('development')['oauth_consumer_key'].should == 'devkey'
    end
  end

  describe '#consumer' do
    it 'should be an OAuth Consumer' do
      TwitterAuth.consumer.should be_a(OAuth::Consumer)
    end

    it 'should use the credentials from #config' do
      TwitterAuth.consumer.key.should == 'testkey'
      TwitterAuth.consumer.secret.should == 'testsecret'
    end

    it 'should use the TwitterAuth base_url' do
      TwitterAuth.consumer.site.should == TwitterAuth.base_url
      TwitterAuth.base_url = 'https://example.com'
      TwitterAuth.consumer.site.should == 'https://example.com'
    end
  end

  describe '#strategy' do
    it 'should pull and symbolize from the config' do
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
end
