require File.dirname(__FILE__) + '/../../spec_helper'

describe TwitterAuth::GenericUser do
  should_validate_presence_of :login
  should_validate_format_of :login, 'some_guy', 'awesome', 'cool_man'
  should_not_validate_format_of :login, 'with-dashes', 'with.periods', 'with spaces'
  should_validate_length_of :login, :in => 1..15
 
  it 'should validate uniqueness of login' do
    Factory.create(:twitter_oauth_user)
    Factory.build(:twitter_oauth_user).should have_at_least(1).errors_on(:login)
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
      lambda{User.new_from_twitter_hash({})}.should raise_error(ArgumentError, 'Invalid hash: must include screen_name.')
    end

    it 'should return a user' do
      User.new_from_twitter_hash({'screen_name' => 'twitterman'}).should be_a(User)
    end

    it 'should assign login to the screen_name' do
      User.new_from_twitter_hash({'screen_name' => 'twitterman'}).login.should == 'twitterman'
    end

    it 'should assign twitter attributes that are provided' do
      u = User.new_from_twitter_hash({'screen_name' => 'twitterman', 'name' => 'Twitter Man', 'description' => 'Saving the world for all Tweet kind.'})
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
end
