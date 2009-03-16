class SessionsController < ApplicationController
  def new
    if TwitterAuth.oauth?
      @request_token = TwitterAuth.consumer.get_request_token
      session[:request_token] = @request_token.token
      session[:request_token_secret] = @request_token.secret
      redirect_to @request_token.authorize_url
    end
  end

  def oauth_callback
    unless session[:request_token] && session[:request_token_secret]
      flash[:error] = 'No authentication information was found in the session. Please try again.'
      redirect_to '/' and return
    end   

    @request_token = OAuth::RequestToken.new(TwitterAuth.consumer, session[:request_token], session[:request_token_secret])

    @access_token = @request_token.get_access_token

   render :text => @request_token.inspect 
  end
end
