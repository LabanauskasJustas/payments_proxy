# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    include RackSessionFix
    respond_to :json

    private

    def respond_with(resource, _opts = {})
      render json: {
        status: { code: 200, message: 'Logged in sucessfully.' },
        data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
      }, status: :ok
    end

    def respond_to_on_destroy
      if current_user
        session_response({ code: 200, message: "Logged out successfully", status: :ok })
      else
        session_response({ code: 401, message: "Couldn't find an active session.", status: :unauthorized })
      end
    end

    private
    
    def session_response(response_params = {})
      render json: {
        status: response_params.fetch(:code),
        message: response_params.fetch(:message)
      }, status: response_params.fetch(:status)
    end
  end
end
