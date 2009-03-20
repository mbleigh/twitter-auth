require File.dirname(__FILE__) + '/../../spec_helper'

describe TwitterAuth::Dispatcher::Oauth do
  before do
    stub_oauth!
    @user = Factory.create(:twitter_oauth_user, :access_token => 'token', :access_secret => 'secret')
  end

  it 'should be a child class of OAuth::AccessToken' do
    TwitterAuth::Dispatcher::Oauth.new(@user).should be_a(OAuth::AccessToken)
  end

  it 'should require initialization of an OauthUser' do
    lambda{TwitterAuth::Dispatcher::Oauth.new(nil)}.should raise_error(TwitterAuth::Error, 'Dispatcher must be initialized with a User.')
  end

  it 'should store the user in an attr_accessor' do
    TwitterAuth::Dispatcher::Oauth.new(@user).user.should == @user
  end

  it "should initialize with the user's token and secret" do
    d = TwitterAuth::Dispatcher::Oauth.new(@user)
    d.token.should == 'token'
    d.secret.should == 'secret'
  end

  describe '#request' do
    before do
      @dispatcher = TwitterAuth::Dispatcher::Oauth.new(@user)
      FakeWeb.register_uri(:get, 'https://twitter.com:443/fake.json', :string => {'fake' => true}.to_json)
      FakeWeb.register_uri(:get, 'https://twitter.com:443/fake.xml', :string => "<fake>true</fake>")
    end
    
    it 'should automatically parse json' do
      result = @dispatcher.request(:get, '/fake.json')
      result.should be_a(Hash)
      result['fake'].should be_true
    end

    it 'should return xml as a string' do
      @dispatcher.request(:get, '/fake.xml').should == '<fake>true</fake>'
    end

    it 'should append .json to the path if no extension is provided' do
      @dispatcher.request(:get, '/fake').should == @dispatcher.request(:get, '/fake.json')
    end

    it 'should work with verb methods' do
      @dispatcher.get('/fake').should == @dispatcher.request(:get, '/fake')
    end
  end
end
