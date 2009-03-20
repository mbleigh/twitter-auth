module TwitterAuth
  module Dispatcher
    module Shared
      def handle_response(response)
        case response
        when Net::HTTPOK 
          begin
            JSON.parse(response.body)
          rescue JSON::ParserError
            response.body
          end
        else
          message = begin
            JSON.parse(response.body)['error']
          rescue JSON::ParserError
            if match = response.body.match(/<error>(.*)<\/error>/)
              match[1]
            else
              'An error occurred processing your Twitter request.'
            end
          end

          raise TwitterAuth::Dispatcher::Error, message
        end
      end
    end
  end
end
