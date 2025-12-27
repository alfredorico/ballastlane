module Api
  module V1
    class BaseController < ApplicationController
      include Authenticatable

      def render_error(message, status: :unprocessable_content, errors: nil)
        response = { error: message }
        response[:details] = errors if errors.present?
        render json: response, status: status
      end

      def render_success(data = {}, status: :ok)
        render json: data, status: status
      end
    end
  end
end
