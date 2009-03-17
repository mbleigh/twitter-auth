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
      authentication_failed('No authentication information was found in the session. Please try again.') and return
    end

   unless params[:oauth_token].blank? || session[:request_token] ==  params[:oauth_token]
     authentication_failed('Authentication information does not match session information. Please try again.') and return
   end

    @request_token = OAuth::RequestToken.new(TwitterAuth.consumer, session[:request_token], session[:request_token_secret])

    @access_token = @request_token.get_access_token

    @user = User.identify_or_create_from_access_token(@access_token)

    session[:user_id] = @user.id

    authentication_succeeded 
  end
end
