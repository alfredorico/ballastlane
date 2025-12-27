require "rails_helper"

RSpec.describe "Api::V1::Auth", type: :request do
  let(:valid_params) do
    {
      username: "testuser",
      password: "password123",
      password_confirmation: "password123"
    }
  end

  describe "POST /api/v1/auth/signup" do
    context "with valid parameters" do
      it "creates a new user and returns tokens" do
        expect {
          post "/api/v1/auth/signup", params: valid_params
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)

        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Account created successfully")
        expect(json["user"]["username"]).to eq("testuser")
        expect(json["access_token"]).to be_present
        expect(json["refresh_token"]).to be_present
        expect(json["token_type"]).to eq("Bearer")
        expect(json["expires_in"]).to eq(900)
      end
    end

    context "with missing username" do
      it "returns validation error" do
        post "/api/v1/auth/signup", params: valid_params.except(:username)

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Signup failed")
        expect(json["details"]).to include("Username can't be blank")
      end
    end

    context "with invalid username format" do
      it "returns validation error for special characters" do
        post "/api/v1/auth/signup", params: valid_params.merge(username: "invalid_user!")

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json["details"]).to include("Username must contain only alphanumeric characters")
      end
    end

    context "with password too short" do
      it "returns validation error" do
        post "/api/v1/auth/signup", params: valid_params.merge(
          password: "1234",
          password_confirmation: "1234"
        )

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json["details"]).to include("Password is too short (minimum is 5 characters)")
      end
    end

    context "with password confirmation mismatch" do
      it "returns validation error" do
        post "/api/v1/auth/signup", params: valid_params.merge(
          password_confirmation: "differentpass"
        )

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json["details"]).to include("Password confirmation doesn't match Password")
      end
    end

    context "with duplicate username" do
      before { create(:user, username: "testuser") }

      it "returns validation error" do
        post "/api/v1/auth/signup", params: valid_params

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json["details"]).to include("Username has already been taken")
      end
    end
  end

  describe "POST /api/v1/auth/login" do
    let!(:user) { create(:user, username: "testuser", password: "password123", password_confirmation: "password123") }

    context "with valid credentials" do
      it "returns tokens and user info" do
        post "/api/v1/auth/login", params: { username: "testuser", password: "password123" }

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Login successful")
        expect(json["user"]["username"]).to eq("testuser")
        expect(json["access_token"]).to be_present
        expect(json["refresh_token"]).to be_present
        expect(json["token_type"]).to eq("Bearer")
      end

      it "regenerates the user JTI" do
        old_jti = user.jti
        post "/api/v1/auth/login", params: { username: "testuser", password: "password123" }
        expect(user.reload.jti).not_to eq(old_jti)
      end
    end

    context "with wrong password" do
      it "returns unauthorized error" do
        post "/api/v1/auth/login", params: { username: "testuser", password: "wrongpassword" }

        expect(response).to have_http_status(:unauthorized)

        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Invalid username or password")
      end
    end

    context "with non-existent user" do
      it "returns unauthorized error" do
        post "/api/v1/auth/login", params: { username: "nonexistent", password: "password123" }

        expect(response).to have_http_status(:unauthorized)

        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Invalid username or password")
      end
    end

    context "with missing parameters" do
      it "returns unauthorized error" do
        post "/api/v1/auth/login", params: {}

        expect(response).to have_http_status(:unauthorized)

        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Invalid username or password")
      end
    end
  end

  describe "DELETE /api/v1/auth/logout" do
    let!(:user) { create(:user) }

    context "with valid access token" do
      it "revokes the session and returns success" do
        access_token = JwtService.encode_access_token(user)
        old_jti = user.jti

        delete "/api/v1/auth/logout", headers: { "Authorization" => "Bearer #{access_token}" }

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Logged out successfully")
        expect(user.reload.jti).not_to eq(old_jti)
      end
    end

    context "with missing authorization header" do
      it "returns unauthorized error" do
        delete "/api/v1/auth/logout"

        expect(response).to have_http_status(:unauthorized)

        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Missing authorization token")
      end
    end

    context "with expired access token" do
      it "returns unauthorized error" do
        access_token = JwtService.encode_access_token(user)

        travel_to 16.minutes.from_now do
          delete "/api/v1/auth/logout", headers: { "Authorization" => "Bearer #{access_token}" }

          expect(response).to have_http_status(:unauthorized)

          json = JSON.parse(response.body)
          expect(json["error"]).to eq("Token has expired")
        end
      end
    end

    context "with revoked token" do
      it "returns unauthorized error" do
        access_token = JwtService.encode_access_token(user)
        user.regenerate_jti!

        delete "/api/v1/auth/logout", headers: { "Authorization" => "Bearer #{access_token}" }

        expect(response).to have_http_status(:unauthorized)

        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Token has been revoked")
      end
    end
  end

  describe "POST /api/v1/auth/refresh_token" do
    let!(:user) { create(:user) }

    context "with valid refresh token" do
      it "returns new token pair" do
        refresh_token = JwtService.encode_refresh_token(user)
        old_jti = user.jti

        post "/api/v1/auth/refresh_token", params: { refresh_token: refresh_token }

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Token refreshed successfully")
        expect(json["access_token"]).to be_present
        expect(json["refresh_token"]).to be_present
        expect(json["token_type"]).to eq("Bearer")
        expect(json["expires_in"]).to eq(900)

        # Verify token rotation (JTI changed)
        expect(user.reload.jti).not_to eq(old_jti)
      end

      it "returns different tokens than the original" do
        refresh_token = JwtService.encode_refresh_token(user)

        post "/api/v1/auth/refresh_token", params: { refresh_token: refresh_token }

        json = JSON.parse(response.body)
        expect(json["refresh_token"]).not_to eq(refresh_token)
      end
    end

    context "with missing refresh_token parameter" do
      it "returns bad request error" do
        post "/api/v1/auth/refresh_token", params: {}

        expect(response).to have_http_status(:bad_request)

        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Refresh token is required")
      end
    end

    context "with expired refresh token" do
      it "returns unauthorized error" do
        refresh_token = JwtService.encode_refresh_token(user)

        travel_to 8.days.from_now do
          post "/api/v1/auth/refresh_token", params: { refresh_token: refresh_token }

          expect(response).to have_http_status(:unauthorized)

          json = JSON.parse(response.body)
          expect(json["error"]).to eq("Refresh token has expired")
        end
      end
    end

    context "with access token instead of refresh token" do
      it "returns unauthorized error" do
        access_token = JwtService.encode_access_token(user)

        post "/api/v1/auth/refresh_token", params: { refresh_token: access_token }

        expect(response).to have_http_status(:unauthorized)

        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Expected refresh token")
      end
    end

    context "with revoked token (JTI mismatch)" do
      it "returns unauthorized error" do
        refresh_token = JwtService.encode_refresh_token(user)
        user.regenerate_jti!

        post "/api/v1/auth/refresh_token", params: { refresh_token: refresh_token }

        expect(response).to have_http_status(:unauthorized)

        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Refresh token has been revoked")
      end
    end

    context "with invalid/malformed token" do
      it "returns unauthorized error" do
        post "/api/v1/auth/refresh_token", params: { refresh_token: "invalid.token.here" }

        expect(response).to have_http_status(:unauthorized)

        json = JSON.parse(response.body)
        expect(json["error"]).to include("Invalid token")
      end
    end
  end
end
