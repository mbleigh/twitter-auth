require File.dirname(__FILE__) + '/../spec_helper'

ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
end

class TwitterAuthTestController < ApplicationController
  before_filter :login_required, :only => [:login_required_action]

  def login_required_action
    render :text => "You are logged in!"
  end

  def fail_auth
    authentication_failed('Auth FAIL.')
  end

  def pass_auth
    if params[:message]
      authentication_succeeded(params[:message])
    else
      authentication_succeeded
    end
  end

  def access_denied_action
    access_denied
  end

  def redirect_back_action
    redirect_back_or_default(params[:to] || '/')
  end

  def logout_keeping_session_action
    logout_keeping_session!
    redirect_back_or_default('/')
  end

  def current_user_action
    @user = current_user
    render :nothing => true
  end
end

describe TwitterAuthTestController do
  before do
    controller.stub!(:cookies).and_return({})
  end

  %w(authentication_failed authentication_succeeded current_user authorized? login_required access_denied store_location redirect_back_or_default logout_keeping_session!).each do |m|
    it "should respond to the extension method '#{m}'" do
      controller.should respond_to(m)
    end
  end

  describe "#authentication_failed" do
    it 'should set the flash[:error] to the message passed in' do
      get :fail_auth
      flash[:error].should == 'Auth FAIL.'
    end

    it 'should redirect to the root' do
      get :fail_auth
      should redirect_to('/')
    end
  end

  describe "#authentication_succeeded" do
    it 'should set the flash[:notice] to a default success message' do
      get :pass_auth
      flash[:notice].should == 'You have logged in successfully.' 
    end

    it 'should be able ot receive a custom message' do
      get :pass_auth, :message => 'Eat at Joes.'
      flash[:notice].should == 'Eat at Joes.'
    end
  end

  describe '#current_user' do
    it 'should find the user based on the session user_id' do
      user = Factory.create(:twitter_oauth_user)
      request.session[:user_id] = user.id
      get(:current_user_action)
      assigns[:user].should == user
    end

    it 'should log the user in through a cookie' do
      user = Factory(:twitter_oauth_user, :remember_token => 'abc', :remember_token_expires_at => (Time.now + 10.days))
      controller.stub!(:cookies).and_return({:remember_token => 'abc'})
      get :current_user_action
      assigns[:user].should == user
    end

    it 'should return nil if there is no user matching that id' do
      request.session[:user_id] = 2345
      get :current_user_action
      assigns[:user].should be_nil
    end
  end

  describe "#authorized?" do
    it 'should be true if there is a current_user' do
      user = Factory.create(:twitter_oauth_user)
      controller.stub!(:current_user).and_return(user)
      controller.send(:authorized?).should be_true
    end

    it 'should be false if there is not current_user' do
      controller.stub!(:current_user).and_return(nil)
      controller.send(:authorized?).should be_false
    end
  end

  describe '#access_denied' do
    it 'should redirect to the login path' do
      get :access_denied_action
      should redirect_to(login_path)
    end

    it 'should store the location first' do
      controller.should_receive(:store_location).once
      get :access_denied_action
    end
  end

  describe '#redirect_back_or_default' do
    it 'should redirect if there is a session[:return_to]' do
      request.session[:return_to] = '/'
      get :redirect_back_action, :to => '/notroot'
      should redirect_to('/')
    end

    it 'should redirect to the default provided otherwise' do
      get :redirect_back_action, :to => '/someurl'
      should redirect_to('/someurl')
    end
  end

  describe 'logout_keeping_session!' do
    before do
      @user = Factory.create(:twitter_oauth_user)
      request.session[:user_id] = @user.id
    end

    it 'should unset session[:user_id]' do
      get :logout_keeping_session_action
      request.session[:user_id].should be_nil
    end

    it 'should unset current_user' do
      controller.send(:current_user).should == @user
      get :logout_keeping_session_action
      controller.send(:current_user).should be_false
    end

    it 'should unset the cookie' do
      controller.send(:cookies).should_receive(:delete).with(:remember_token)
      get :logout_keeping_session_action
    end
  end
end
