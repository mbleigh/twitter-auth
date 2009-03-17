require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController do
  describe 'routes' do
    it 'should route /session/new to SessionsController#new' do
      params_from(:get, '/session/new').should == {:controller => 'sessions', :action => 'new'}
    end

    it 'should route /oauth_callback to SessionsController#oauth_callback' do
      params_from(:get, '/oauth_callback').should == {:controller => 'sessions', :action => 'oauth_callback'}
    end
  end

  describe 'with OAuth strategy' do
    before do
      stub_oauth!
    end

    describe '#new' do
      it 'should retrieve a request token' do
        get :new
        assigns[:request_token].token.should == 'faketoken'
        assigns[:request_token].secret.should == 'faketokensecret'
      end

      it 'should set session variables for the request token' do
        get :new
        session[:request_token].should == 'faketoken'
        session[:request_token_secret].should == 'faketokensecret'
      end

      it 'should redirect to the oauth authorization url' do
        get :new
        response.should redirect_to('https://twitter.com/oauth/authorize?oauth_token=faketoken')
      end
    end

    describe '#oauth_callback' do
      describe 'with no session info' do
        it 'should set the flash[:error]' do
          get :oauth_callback
          flash[:error].should == 'No authentication information was found in the session. Please try again.'
        end

        it 'should redirect to "/"' do
          get :oauth_callback
          response.should redirect_to('/')
        end
      end

      describe 'with proper info' do
        before do
          @user = Factory.create(:twitter_oauth_user)
          request.session[:request_token] = 'faketoken'
          request.session[:request_token_secret] = 'faketokensecret'
          get :oauth_callback, :oauth_token => 'faketoken'
        end

        describe 'building the access token' do

          it 'should rebuild the request token' do
            correct_token =  OAuth::RequestToken.new(TwitterAuth.consumer,'faketoken','faketokensecret')
            
            %w(token secret).each do |att|
              assigns[:request_token].send(att).should == correct_token.send(att)
            end
          end

          it 'should exchange the request token for an access token' do
            assigns[:access_token].should be_a(OAuth::AccessToken)
            assigns[:access_token].token.should == 'fakeaccesstoken'
            assigns[:access_token].secret.should == 'fakeaccesstokensecret'
          end
        end
        
        describe 'identifying the user' do
          it "should find the user" do         
            assigns[:user].should == @user
          end

          it "should assign the user id to the session" do
            session[:user_id].should == @user.id
          end
        end
      end
    end
  end
end
