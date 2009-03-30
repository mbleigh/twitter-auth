require File.dirname(__FILE__) + '/../../spec_helper'

describe TwitterAuth::Dispatcher::Basic do
  before do
    stub_basic!
    @user = Factory.create(:twitter_basic_user, :login => 'twitterman', :password => 'test')
  end

  it 'should require a user as the initialization argument' do
    lambda{TwitterAuth::Dispatcher::Basic.new(nil)}.should raise_error(TwitterAuth::Error, 'Dispatcher must be initialized with a User.')
  end

  it 'should store the user in an attr_accessor' do
    TwitterAuth::Dispatcher::Basic.new(@user).user.should == @user
  end

  describe '#request' do
    before do
      @dispatcher = TwitterAuth::Dispatcher::Basic.new(@user)
      FakeWeb.register_uri('https://twitter.com:443/fake.json', :string => {'fake' => true}.to_json)
        FakeWeb.register_uri('https://twitter.com:443/fake.xml', :string => '<fake>true</fake>')
    end
    
    it 'should automatically parse JSON if valid' do
       @dispatcher.request(:get, '/fake.json').should == {'fake' => true}
    end

    it 'should return XML as a string' do
      @dispatcher.request(:get, '/fake.xml').should == "<fake>true</fake>"
    end

    it 'should append .json to the path if no extension is provided' do
      @dispatcher.request(:get, '/fake.json').should == @dispatcher.request(:get, '/fake')
    end

    %w(get post put delete).each do |method|
      it "should build a #{method} class based on a :#{method} http_method" do
        @req = "Net::HTTP::#{method.capitalize}".constantize.new('/fake.json')
        "Net::HTTP::#{method.capitalize}".constantize.should_receive(:new).and_return(@req)
        @dispatcher.request(method.to_sym, '/fake')
      end
    end

    it 'should start the HTTP session' do
      @net = TwitterAuth.net
      TwitterAuth.stub!(:net).and_return(@net)
      @net.should_receive(:start)
      lambda{@dispatcher.request(:get, '/fake')}.should raise_error(NoMethodError)
    end

    it "should raise a TwitterAuth::Dispatcher::Error if response code isn't 200" do
      FakeWeb.register_uri('https://twitter.com:443/bad_response.json', :string => {'error' => 'bad response'}.to_json, :status => ['401', 'Unauthorized'])
      lambda{@dispatcher.request(:get, '/bad_response')}.should raise_error(TwitterAuth::Dispatcher::Error)
    end

    it 'should set the error message to the JSON message' do
      FakeWeb.register_uri('https://twitter.com:443/bad_response.json', :string => {'error' => 'bad response'}.to_json, :status => ['403', 'Forbidden'])
      lambda{@dispatcher.request(:get, '/bad_response')}.should raise_error(TwitterAuth::Dispatcher::Error, 'bad response')
    end

    it 'should raise a TwitterAuth::Dispatcher::Unauthorized on 401' do
      FakeWeb.register_uri('https://twitter.com:443/unauthenticated_response.xml', :string => "<hash>\n<request>/unauthenticated_response.xml</request>\n<error>bad response</error>\n</hash>", :status => ['401', 'Unauthorized'])
      lambda{@dispatcher.request(:get, '/unauthenticated_response.xml')}.should raise_error(TwitterAuth::Dispatcher::Unauthorized)
    end

    it 'should set the error message to the XML message' do
      FakeWeb.register_uri('https://twitter.com:443/bad_response.xml', :string => "<hash>\n<request>/bad_response.xml</request>\n<error>bad response</error>\n</hash>", :status => ['403', 'Forbidden'])
      lambda{@dispatcher.request(:get, '/bad_response')}.should raise_error(TwitterAuth::Dispatcher::Error, 'bad response')
    end
  end

  %w(get post delete put).each do |method|
    it "should have a ##{method} method that calls request(:#{method})" do
      dispatcher = TwitterAuth::Dispatcher::Basic.new(@user)
      if %w(get delete).include?(method)
        dispatcher.should_receive(:request).with(method.to_sym, '/fake.json')
      else
        dispatcher.should_receive(:request).with(method.to_sym, '/fake.json', '')
      end
      dispatcher.send(method, '/fake.json')
    end
  end
end
