require File.dirname(__FILE__) + '/../../spec_helper'

describe TwitterAuth::BasicUser do
  before do
    stub_basic!
  end

  describe '#password=' do
    before do
      @user = Factory.build(:twitter_basic_user)
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
end
