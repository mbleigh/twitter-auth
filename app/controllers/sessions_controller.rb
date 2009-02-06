# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  def new
    
  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      # new_cookie_flag = (params[:remember_me] == "1")
      # handle_remember_cookie! new_cookie_flag
      flash[:notice] = "Logged in successfully"      
      redirect_back_or_default('/')
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end
  
  def confirm
    if session.id == params[:session_id] && current_user.id == params[:client_id].to_i
      render :text => "Identity Confirmed.", :layout => false
    else
      render :text => "Unable to confirm identity.", :status => 403
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

protected

  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
