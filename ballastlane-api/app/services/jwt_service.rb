class JwtService
  ACCESS_TOKEN_EXPIRY = 15.minutes
  REFRESH_TOKEN_EXPIRY = 1.week

  ACCESS_TOKEN_TYPE = "access".freeze
  REFRESH_TOKEN_TYPE = "refresh".freeze

  class TokenError < StandardError; end
  class TokenExpiredError < TokenError; end
  class InvalidTokenError < TokenError; end
  class TokenRevokedError < TokenError; end

  class << self
    def encode_access_token(user)
      encode(user, ACCESS_TOKEN_TYPE, ACCESS_TOKEN_EXPIRY)
    end

    def encode_refresh_token(user)
      encode(user, REFRESH_TOKEN_TYPE, REFRESH_TOKEN_EXPIRY)
    end

    def generate_tokens(user)
      {
        access_token: encode_access_token(user),
        refresh_token: encode_refresh_token(user),
        token_type: "Bearer",
        expires_in: ACCESS_TOKEN_EXPIRY.to_i
      }
    end

    def decode(token)
      body = JWT.decode(
        token,
        secret_key,
        true,
        { algorithm: algorithm }
      ).first

      HashWithIndifferentAccess.new(body)
    rescue JWT::ExpiredSignature
      raise TokenExpiredError, "Token has expired"
    rescue JWT::DecodeError => e
      raise InvalidTokenError, "Invalid token: #{e.message}"
    end

    def validate_access_token(token)
      payload = decode(token)
      validate_token_type!(payload, ACCESS_TOKEN_TYPE)
      find_and_validate_user(payload)
    end

    def validate_refresh_token(token)
      payload = decode(token)
      validate_token_type!(payload, REFRESH_TOKEN_TYPE)
      find_and_validate_user(payload)
    end

    private

    def encode(user, token_type, expiry)
      payload = {
        sub: user.id,
        jti: user.jti,
        type: token_type,
        iat: Time.current.to_i,
        exp: expiry.from_now.to_i
      }

      JWT.encode(payload, secret_key, algorithm)
    end

    def validate_token_type!(payload, expected_type)
      unless payload[:type] == expected_type
        raise InvalidTokenError, "Expected #{expected_type} token"
      end
    end

    def find_and_validate_user(payload)
      user = User.find_by(id: payload[:sub])

      raise InvalidTokenError, "User not found" unless user
      raise TokenRevokedError, "Token has been revoked" unless user.jti == payload[:jti]

      user
    end

    def secret_key
      Rails.application.credentials.secret_key_base ||
        ENV.fetch("SECRET_KEY_BASE") { raise "SECRET_KEY_BASE not configured" }
    end

    def algorithm
      "HS256"
    end
  end
end
