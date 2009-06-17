module TwitterAuth
  # These methods borrow HEAVILY from Rick Olsen's
  # Restful Authentication. All cleverness props
  # go to him, not me.
  module ControllerExtensions
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?, :authorized?
    end

    protected

    def authentication_failed(message, destination='/')
      flash[:error] = message
      redirect_to destination
    end

    def authentication_succeeded(message = 'You have logged in successfully.', destination = '/')
      flash[:notice] = message
      redirect_back_or_default destination
    end

    def current_user
      @current_user ||= 
        if session[:user_id]
          User.find_by_id(session[:user_id])
        elsif cookies[:remember_token]
          User.from_remember_token(cookies[:remember_token])
        else
          false
        end
    end

    def current_user=(new_user)
      session[:user_id] = new_user.id
      @current_user = new_user
    end

    def authorized?
      !!current_user
    end

    def login_required
      authorized? || access_denied 
    end

    def access_denied
      store_location
      redirect_to login_path
    end

    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    def logged_in?
      !!current_user
    end

    def logout_keeping_session!
      session[:user_id] = nil
      @current_user = nil
      cookies.delete(:remember_token)
    end
  end
end

ActionController::Base.send(:include, TwitterAuth::ControllerExtensions)
