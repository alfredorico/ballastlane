module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate!
    attr_reader :current_user
  end

  private

  def authenticate!
    token = extract_token_from_header

    if token.blank?
      render_unauthorized("Missing authorization token")
      return
    end

    begin
      @current_user = JwtService.validate_access_token(token)
    rescue JwtService::TokenExpiredError
      render_unauthorized("Token has expired")
    rescue JwtService::TokenRevokedError
      render_unauthorized("Token has been revoked")
    rescue JwtService::InvalidTokenError => e
      render_unauthorized(e.message)
    end
  end

  def extract_token_from_header
    header = request.headers["Authorization"]
    return nil unless header

    header.split(" ").last
  end

  def render_unauthorized(message = "Unauthorized")
    render json: { error: message }, status: :unauthorized
  end
end
