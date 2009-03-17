module TwitterAuth
  module ControllerExtensions
    protected

    def authentication_failed
      redirect_to '/'
    end
  end
end

ActionController::Base.send(:include, TwitterAuth::ControllerExtensions)
