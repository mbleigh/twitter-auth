require File.dirname(__FILE__) + '/../../spec_helper'

describe TwitterAuth::OauthUser do
  before do
    stub_oauth!
  end
 
  describe '.identify_or_create_from_access_token' do
    before do
       @token = OAuth::AccessToken.new(TwitterAuth.consumer, 'faketoken', 'fakesecret')
    end

    it 'should accept an OAuth::AccessToken' do
      lambda{ User.identify_or_create_from_access_token(@token) }.should_not raise_error(ArgumentError)
    end

    it 'should accept two strings' do
      lambda{ User.identify_or_create_from_access_token('faketoken', 'fakesecret') }.should_not raise_error(ArgumentError)
    end

    it 'should not accept one string' do
      lambda{ User.identify_or_create_from_access_token('faketoken') }.should raise_error(ArgumentError, 'Must authenticate with an OAuth::AccessToken or the string access token and secret.')
    end

    it 'should make a call to verify_credentials' do
      # this is in the before, just making it explicit
      User.identify_or_create_from_access_token(@token)
    end

    it 'should try to find the user with that login' do
      User.should_receive(:find_by_login).once.with('twitterman')
      User.identify_or_create_from_access_token(@token)
    end

    it 'should return the user if he/she exists' do
      user = Factory.create(:twitter_oauth_user, :login => 'twitterman')
      User.identify_or_create_from_access_token(@token).should == user
    end

    it 'should update the user\'s attributes based on the twitter info' do
      user = Factory.create(:twitter_oauth_user, :login => 'twitterman', :name => 'Not Twitter Man')
      User.identify_or_create_from_access_token(@token).name.should == 'Twitter Man'
    end

    it 'should create a user if one does not exist' do
      lambda{User.identify_or_create_from_access_token(@token)}.should change(User, :count).by(1)
    end

    it 'should assign the oauth access token and secret' do
      user = User.identify_or_create_from_access_token(@token)
      user.access_token.should == @token.token
      user.access_secret.should == @token.secret
    end
  end
end
