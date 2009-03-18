module TwitterAuth
  # These methods borrow HEAVILY from Rick Olsen's
  # Restful Authentication. All cleverness props
  # go to him, not me.
  module ControllerExtensions
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?, :authorized?
    end

    protected

    def authentication_failed(message)
      flash[:error] = message
      redirect_to '/'
    end

    def authentication_succeeded(message = 'You have logged in successfully.')
      flash[:notice] = message
      redirect_to '/'
    end

    def current_user
      @current_user ||= User.find_by_id(session[:user_id])
    end

    def authorized?
      !!current_user
    end

    def login_required

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
      @current_user = nil
      session[:user_id] = nil
    end
  end
end

ActionController::Base.send(:include, TwitterAuth::ControllerExtensions)
