require File.dirname(__FILE__) + '/../../spec_helper'

describe TwitterAuth::BasicUser do
  before do
    stub_basic!
  end

  describe '#password=' do
    before do
      @user = Factory.build(:twitter_basic_user, :twitter_id => '123')
    end

    it 'should change the value of crypted_password' do
      lambda{@user.password = 'newpass'}.should change(@user, :crypted_password)
    end

    it 'should change the value of salt' do
      lambda{@user.password = 'newpass'}.should change(@user, :salt)
    end

    it 'should not store the plaintext password' do
      @user.password = 'newpass'
      @user.crypted_password.should_not == 'newpass'
    end
  end

  describe '#password' do
    before do
      @user = Factory.build(:twitter_basic_user, :password => 'monkey')
    end

    it 'should return the password' do
      @user.password.should == 'monkey'
    end    

    it 'should not be a database attribute' do
      @user['password'].should_not == 'monkey'
    end
  end
  
  describe '.verify_credentials' do
    before do
      @user = Factory.create(:twitter_basic_user)
    end

    it 'should return a JSON hash of the user when successful' do
      hash = User.verify_credentials('twitterman','test')
      hash.should be_a(Hash)
      hash['screen_name'].should == 'twitterman'
      hash['name'].should == 'Twitter Man'
    end

    it 'should return false when a 401 unauthorized happens' do
      FakeWeb.register_uri(:get, 'https://twitter.com:443/account/verify_credentials.json', :string => '401 "Unauthorized"', :status => ['401',' Unauthorized'])
      User.verify_credentials('twitterman','wrong').should be_false
    end
  end

  describe '.authenticate' do
    before do
      @user = Factory.create(:twitter_basic_user, :twitter_id => '123')
    end

    it 'should make a call to verify_credentials' do
      User.should_receive(:verify_credentials).with('twitterman','test')
      User.authenticate('twitterman','test')
    end

    it 'should return nil if verify_credentials returns false' do
      User.stub!(:verify_credentials).and_return(false)
      User.authenticate('twitterman','test').should be_nil
    end

    it 'should return the user if verify_credentials succeeds' do
      User.stub!(:verify_credentials).and_return(JSON.parse("{\"profile_image_url\":\"http:\\/\\/static.twitter.com\\/images\\/default_profile_normal.png\",\"description\":\"Saving the world for all Twitter kind.\",\"utc_offset\":null,\"favourites_count\":0,\"profile_sidebar_fill_color\":\"e0ff92\",\"screen_name\":\"twitterman\",\"statuses_count\":0,\"profile_background_tile\":false,\"profile_sidebar_border_color\":\"87bc44\",\"friends_count\":2,\"url\":null,\"name\":\"Twitter Man\",\"time_zone\":null,\"protected\":false,\"profile_background_image_url\":\"http:\\/\\/static.twitter.com\\/images\\/themes\\/theme1\\/bg.gif\",\"profile_background_color\":\"9ae4e8\",\"created_at\":\"Fri Feb 06 18:10:32 +0000 2009\",\"profile_text_color\":\"000000\",\"followers_count\":2,\"location\":null,\"id\":123,\"profile_link_color\":\"0000ff\"}"))
      User.authenticate('twitterman','test').should == @user
    end
  end

  describe '.find_or_create_by_twitter_hash_and_password' do
    before do
      @user = Factory.create(:twitter_basic_user, :twitter_id => '123')
    end

    it 'should return the existing user if there is one' do
      User.identify_or_create_from_twitter_hash_and_password({'id' => '123', 'screen_name' => 'twitterman'},'test').should == @user
    end

    it 'should update the attributes from the hash' do
      User.identify_or_create_from_twitter_hash_and_password({'id' => 123, 'screen_name' => 'twitterman', 'name' => 'New Name'}, 'test').name.should == 'New Name'
    end

    it 'should update the password from the argument' do
      User.identify_or_create_from_twitter_hash_and_password({'id' => '123', 'screen_name' => 'twitterman', 'name' => 'New Name'}, 'test2').password.should == 'test2'
    end

    it 'should create a user if one does not exist' do
      lambda{User.identify_or_create_from_twitter_hash_and_password({'id' => 124, 'screen_name' => 'dude', 'name' => "Lebowski"}, 'test')}.should change(User, :count).by(1)
    end

    it 'should assign the attributes from the hash to a created user' do
      user = User.identify_or_create_from_twitter_hash_and_password({'id' => 124, 'screen_name' => 'dude', 'name' => "Lebowski"}, 'test')
      user.twitter_id.should == '124'
      user.login.should == 'dude'
      user.name.should == 'Lebowski'
      user.password.should == 'test'
    end
  end

  describe '#twitter' do
    before do
      @user = Factory.create(:twitter_basic_user, :twitter_id => '123')
    end

    it 'should be an instance of TwitterAuth::Dispatcher::Basic' do
      @user.twitter.class.should == TwitterAuth::Dispatcher::Basic
    end

    it 'should have the correct user set' do
      @user.twitter.user.should == @user
    end
  end

  describe 'changing usernames' do
    before do
      @user = Factory.create(:twitter_basic_user, :twitter_id => '123')
    end

    it 'should not create a new record when a screen_name has changed' do
      lambda{User.identify_or_create_from_twitter_hash_and_password({'id' => '123', 'screen_name' => 'dude'},'awesome')}.should_not change(User,:count)
    end

    it 'should update the record with the new screen name' do
      User.identify_or_create_from_twitter_hash_and_password({'id' => '123', 'screen_name' => 'dude'},'awesome').should == @user.reload
      @user.login.should == 'dude'
    end
  end
end
