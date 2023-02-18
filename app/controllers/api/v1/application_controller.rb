module Api
  module V1
    class ApplicationController < ActionController::API
      skip_before_action :verify_authenticity_token
      before_action :authenticate!

      def authenticate!
        authenticate_token || render_unauthorized
      end

      def authenticate_token
        authenticate_with_http_token do |token, _options|
          @current_user = User.find_by(jti: token)
        end
      end

      def render_unauthorized(realm = 'Application')
        headers['WWW-Authenticate'] = %(Token realm="#{realm}")
        render json: { status: :unauthorized, code: 401, errors: ['Bad credentials'], messages: [], result: {} }, status: :unauthorized
      end
    end
  end
end
