require File.dirname(__FILE__) + '/../../spec_helper'

describe TwitterAuth::GenericUser do
  should_validate_presence_of :login, :twitter_id
  should_validate_format_of :login, 'some_guy', 'awesome', 'cool_man'
  should_not_validate_format_of :login, 'with-dashes', 'with.periods', 'with spaces'
  should_validate_length_of :login, :in => 1..15
  
  it 'should validate uniqueness of login' do
    Factory.create(:twitter_oauth_user)
    Factory.build(:twitter_oauth_user).should have_at_least(1).errors_on(:login)
  end

  it 'should validate uniqueness of remember_token' do
    Factory.create(:twitter_oauth_user, :remember_token => 'abc')
    Factory.build(:twitter_oauth_user, :remember_token => 'abc').should have_at_least(1).errors_on(:remember_token)
  end

  it 'should allow capital letters in the username' do
    Factory.build(:twitter_oauth_user, :login => 'TwitterMan').should have(:no).errors_on(:login)
  end

  it 'should not allow the same login with different capitalization' do
    Factory.create(:twitter_oauth_user, :login => 'twitterman')
    Factory.build(:twitter_oauth_user, :login => 'TwitterMan').should have_at_least(1).errors_on(:login)
  end

  describe '.new_from_twitter_hash' do
    it 'should raise an argument error if the hash does not have a screen_name attribute' do
      lambda{User.new_from_twitter_hash({'id' => '123'})}.should raise_error(ArgumentError, 'Invalid hash: must include screen_name.')
    end

    it 'should raise an argument error if the hash does not have an id attribute' do
      lambda{User.new_from_twitter_hash({'screen_name' => 'abc123'})}.should raise_error(ArgumentError, 'Invalid hash: must include id.')
    end

    it 'should return a user' do
      User.new_from_twitter_hash({'id' => '123', 'screen_name' => 'twitterman'}).should be_a(User)
    end

    it 'should assign login to the screen_name' do
      User.new_from_twitter_hash({'id' => '123', 'screen_name' => 'twitterman'}).login.should == 'twitterman'
    end

    it 'should assign twitter attributes that are provided' do
      u = User.new_from_twitter_hash({'id' => '4566', 'screen_name' => 'twitterman', 'name' => 'Twitter Man', 'description' => 'Saving the world for all Tweet kind.'})
      u.name.should == 'Twitter Man'
      u.description.should == 'Saving the world for all Tweet kind.'
    end
  end

  describe '#update_twitter_attributes' do
    it 'should assign values to the user' do
      user = Factory.create(:twitter_oauth_user, :name => "Dude", :description => "Awesome, man.")
      user.update_twitter_attributes({'name' => 'Twitter Man', 'description' => 'Works.'})
      user.reload
      user.name.should == 'Twitter Man'
      user.description.should == 'Works.'
    end

    it 'should not throw an error with extraneous info' do
      user = Factory.create(:twitter_oauth_user, :name => "Dude", :description => "Awesome, man.")
      lambda{user.update_twitter_attributes({'name' => 'Twitter Man', 'description' => 'Works.', 'whoopsy' => 'noworks.'})}.should_not raise_error
    end
  end

  describe '#remember_me' do
    before do
      @user = Factory(:twitter_oauth_user)
    end

    it 'should check for the remember_token column' do
      @user.should_receive(:respond_to?).with(:remember_token).and_return(false)
      @user.remember_me
    end

    it 'should return nil if there is no remember_token column' do
      @user.should_receive(:respond_to?).with(:remember_token).and_return(false)
      @user.remember_me.should be_false
    end
    
    describe ' with proper columns' do
      it 'should generate a secure random token' do
        ActiveSupport::SecureRandom.should_receive(:hex).with(10).and_return('abcdef')
        @user.remember_me
        @user.remember_token.should == 'abcdef'
      end

      it 'should set the expiration to the current time plus the remember_for period' do
        TwitterAuth.stub!(:remember_for).and_return(10)
        time = Time.now
        Time.stub!(:now).and_return(time)

        @user.remember_me

        @user.remember_token_expires_at.should == Time.now + 10.days
      end

      it 'should return a hash with a :value and :expires key' do
        result = @user.remember_me
        result.should be_a(Hash)
        result.key?(:value).should be_true
        result.key?(:expires).should be_true
      end

      it 'should return a hash with appropriate values' do
        TwitterAuth.stub!(:remember_for).and_return(10)
        time = Time.now
        Time.stub!(:now).and_return(time)
        ActiveSupport::SecureRandom.stub!(:hex).and_return('abcdef')

        @user.remember_me.should == {:value => 'abcdef', :expires => (Time.now + 10.days)}
      end
    end
  end

  describe '#forget_me' do
    it 'should reset remember_token and remember_token_expires_at' do
      @user = Factory(:twitter_oauth_user, :remember_token => "abcdef", :remember_token_expires_at => Time.now + 10.days)
      @user.forget_me
      @user.reload
      @user.remember_token.should be_nil
      @user.remember_token_expires_at.should be_nil
    end
  end

  describe '.from_remember_token' do
    before do
      @user = Factory(:twitter_oauth_user, :remember_token => 'abcdef', :remember_token_expires_at => (Time.now + 10.days))
    end

    it 'should find the user with the specified remember_token' do
      User.from_remember_token('abcdef').should == @user
    end

    it 'should not find a user with an expired token' do
      user2 = Factory(:twitter_oauth_user, :login => 'walker', :remember_token => 'ghijkl', :remember_token_expires_at => (Time.now - 10.days))
      User.from_remember_token('ghijkl').should be_nil
    end

    it 'should not find a user with a nil token and an expiration' do
      user = Factory(:twitter_oauth_user, :login => 'stranger', :remember_token => nil, :remember_token_expires_at => (Time.now + 10.days))
      User.from_remember_token(nil).should be_nil
    end
  end
end
