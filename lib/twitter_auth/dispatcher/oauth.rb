require 'oauth'

module TwitterAuth
  module Dispatcher
    class Oauth < OAuth::AccessToken
      include TwitterAuth::Dispatcher::Shared

      attr_accessor :user

      def initialize(user)
        raise TwitterAuth::Error, 'Dispatcher must be initialized with a User.' unless user.is_a?(TwitterAuth::OauthUser) 
        self.user = user
        super(TwitterAuth.consumer, user.access_token, user.access_secret)
      end

      def request(http_method, path, *arguments)
        path = TwitterAuth.path_prefix + path
        path = append_extension_to(path)

        response = super

        handle_response(response)
      end
    end
  end
end
