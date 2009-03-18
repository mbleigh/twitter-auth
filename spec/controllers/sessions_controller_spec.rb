require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController do
  describe 'routes' do
    it 'should route /session/new to SessionsController#new' do
      params_from(:get, '/session/new').should == {:controller => 'sessions', :action => 'new'}
    end

    it 'should route /login to SessionsController#new' do
      params_from(:get, '/login').should == {:controller => 'sessions', :action => 'new'}
    end

    it 'should route /logout to SessionsController#destroy' do
      params_from(:get, '/logout').should == {:controller => 'sessions', :action => 'destroy'}
    end

    it 'should route DELETE /session to SessionsController#destroy' do
      params_from(:delete, '/session').should == {:controller => 'sessions', :action => 'destroy'}
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

      it 'should redirect to the oauth_callback if one is specified' do
        TwitterAuth.stub!(:oauth_callback).and_return('http://localhost:3000/development')
        TwitterAuth.stub!(:oauth_callback?).and_return(true)        

        get :new
        response.should redirect_to('https://twitter.com/oauth/authorize?oauth_token=faketoken&oauth_callback=' + CGI.escape(TwitterAuth.oauth_callback))
      end
    end

    describe '#oauth_callback' do
      describe 'with no session info' do
        it 'should set the flash[:error]' do
          get :oauth_callback, :oauth_token => 'faketoken'
          flash[:error].should == 'No authentication information was found in the session. Please try again.'
        end

        it 'should redirect to "/" by default' do
          get :oauth_callback, :oauth_token => 'faketoken'
          response.should redirect_to('/')
        end

        it 'should call authentication_failed' do
          controller.should_receive(:authentication_failed).any_number_of_times
          get :oauth_callback, :oauth_token => 'faketoken'
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

          it 'should wipe the request token after exchange' do
            session[:request_token].should be_nil
            session[:request_token_secret].should be_nil
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

        describe "when OAuth doesn't work" do
          before do
            request.session[:request_token] = 'faketoken'
            request.session[:request_token_secret] = 'faketokensecret'
            @request_token =  OAuth::RequestToken.new(TwitterAuth.consumer, session[:request_token], session[:request_token_secret])
            OAuth::RequestToken.stub!(:new).and_return(@request_token)
          end

          it 'should call authentication_failed when it gets a 401 from OAuth' do
            @request_token.stub!(:get_access_token).and_raise(Net::HTTPServerException.new('401 "Unauthorized"', '401 "Unauthorized"'))
            controller.should_receive(:authentication_failed).with('This authentication request is no longer valid. Please try again.')
            # the should raise_error is hacky because of the expectation
            # stubbing the proper behavior :-(
            lambda{get :oauth_callback, :oauth_token => 'faketoken'}.should raise_error(ActionView::MissingTemplate)
          end

          it 'should call authentication_failed when it gets a different HTTPServerException' do
            @request_token.stub!(:get_access_token).and_raise(Net::HTTPServerException.new('404 "Not Found"', '404 "Not Found"'))
            controller.should_receive(:authentication_failed).with('There was a problem trying to authenticate you. Please try again.')
            lambda{get :oauth_callback, :oauth_token => 'faketoken'}.should raise_error(ActionView::MissingTemplate)
          end
        end
      end
    end
  end

  describe '#destroy' do
    it 'should call logout_keeping_session!' do
      controller.should_receive(:logout_keeping_session!).once
      get :destroy
    end

    it 'should redirect to the root' do
      get :destroy
      response.should redirect_to('/')
    end
  end
end
