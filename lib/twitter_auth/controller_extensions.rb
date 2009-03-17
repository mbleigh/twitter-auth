module TwitterAuth
  module ControllerExtensions
    protected

    def authentication_failed(message)
      flash[:error] = message
      redirect_to '/'
    end

    def authentication_succeeded
      redirect_to '/'
    end
  end
end

ActionController::Base.send(:include, TwitterAuth::ControllerExtensions)
