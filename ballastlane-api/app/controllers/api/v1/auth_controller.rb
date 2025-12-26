module Api
  module V1
    class AuthController < BaseController
      skip_before_action :authenticate!, only: [ :signup, :login, :refresh_token ]

      # POST /api/v1/auth/signup
      def signup
        user = User.new(signup_params)

        if user.save
          tokens = JwtService.generate_tokens(user)
          render_success({
            message: "Account created successfully",
            user: user_response(user),
            **tokens
          }, status: :created)
        else
          render_error("Signup failed", errors: user.errors.full_messages)
        end
      end

      # POST /api/v1/auth/login
      def login
        user = User.find_by(username: params[:username]&.strip)

        if user&.authenticate(params[:password])
          user.regenerate_jti!
          tokens = JwtService.generate_tokens(user)

          render_success({
            message: "Login successful",
            user: user_response(user),
            **tokens
          })
        else
          render_error("Invalid username or password", status: :unauthorized)
        end
      end

      # DELETE /api/v1/auth/logout
      def logout
        current_user.revoke_jwt!
        render_success({ message: "Logged out successfully" })
      end

      # POST /api/v1/auth/refresh_token
      def refresh_token
        refresh_token_value = params[:refresh_token]

        if refresh_token_value.blank?
          return render_error("Refresh token is required", status: :bad_request)
        end

        begin
          user = JwtService.validate_refresh_token(refresh_token_value)
          user.regenerate_jti!
          tokens = JwtService.generate_tokens(user)

          render_success({
            message: "Token refreshed successfully",
            **tokens
          })
        rescue JwtService::TokenExpiredError
          render_error("Refresh token has expired", status: :unauthorized)
        rescue JwtService::TokenRevokedError
          render_error("Refresh token has been revoked", status: :unauthorized)
        rescue JwtService::InvalidTokenError => e
          render_error(e.message, status: :unauthorized)
        end
      end

      private

      def signup_params
        params.permit(:username, :password, :password_confirmation)
      end

      def user_response(user)
        {
          id: user.id,
          username: user.username,
          created_at: user.created_at
        }
      end
    end
  end
end
