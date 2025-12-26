class User < ApplicationRecord
  has_secure_password

  USERNAME_FORMAT = /\A[a-zA-Z0-9]+\z/
  PASSWORD_SPECIAL_CHARS = ".-!*#"
  PASSWORD_FORMAT = /\A[a-zA-Z0-9.\-!*#]+\z/

  before_validation :strip_username
  before_validation :ensure_jti, on: :create

  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: {
              with: USERNAME_FORMAT,
              message: "must contain only alphanumeric characters"
            }

  validates :password,
            length: { minimum: 5, maximum: 64 },
            format: {
              with: PASSWORD_FORMAT,
              message: "must contain only alphanumeric characters and special characters (#{PASSWORD_SPECIAL_CHARS})"
            },
            if: -> { password.present? }

  validates :jti, presence: true, uniqueness: true

  def regenerate_jti!
    update!(jti: generate_jti_token)
  end

  def revoke_jwt!
    regenerate_jti!
  end

  private

  def strip_username
    self.username = username.to_s.strip
  end

  def ensure_jti
    self.jti ||= generate_jti_token
  end

  def generate_jti_token
    SecureRandom.uuid
  end
end
