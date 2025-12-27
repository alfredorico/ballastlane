require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    subject { build(:user) }

    context "username" do
      it { is_expected.to validate_presence_of(:username) }

      it "validates uniqueness of username (case-insensitive)" do
        create(:user, username: "TestUser")
        duplicate_user = build(:user, username: "testuser")
        expect(duplicate_user).not_to be_valid
        expect(duplicate_user.errors[:username]).to include("has already been taken")
      end

      it "allows alphanumeric usernames" do
        user = build(:user, username: "ValidUser123")
        expect(user).to be_valid
      end

      it "rejects usernames with special characters" do
        user = build(:user, username: "invalid_user!")
        expect(user).not_to be_valid
        expect(user.errors[:username]).to include("must contain only alphanumeric characters")
      end

      it "rejects usernames with spaces" do
        user = build(:user, username: "invalid user")
        expect(user).not_to be_valid
      end
    end

    context "password" do
      it "requires minimum 5 characters" do
        user = build(:user, password: "1234", password_confirmation: "1234")
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("is too short (minimum is 5 characters)")
      end

      it "requires maximum 64 characters" do
        long_password = "a" * 65
        user = build(:user, password: long_password, password_confirmation: long_password)
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("is too long (maximum is 64 characters)")
      end

      it "allows alphanumeric passwords" do
        user = build(:user, password: "ValidPass123", password_confirmation: "ValidPass123")
        expect(user).to be_valid
      end

      it "allows special characters .-!*#" do
        user = build(:user, password: "Pass.word-123!*#", password_confirmation: "Pass.word-123!*#")
        expect(user).to be_valid
      end

      it "rejects invalid special characters" do
        user = build(:user, password: "password@123", password_confirmation: "password@123")
        expect(user).not_to be_valid
        expect(user.errors[:password].first).to include("must contain only alphanumeric")
      end
    end

    context "jti" do
      it "validates presence of jti on update" do
        user = create(:user)
        user.jti = nil
        expect(user).not_to be_valid
        expect(user.errors[:jti]).to include("can't be blank")
      end

      it "validates uniqueness of jti" do
        existing_user = create(:user)
        new_user = build(:user, jti: existing_user.jti)
        expect(new_user).not_to be_valid
        expect(new_user.errors[:jti]).to include("has already been taken")
      end
    end
  end

  describe "callbacks" do
    describe "#strip_username" do
      it "strips leading whitespace from username" do
        user = create(:user, username: "  testuser")
        expect(user.username).to eq("testuser")
      end

      it "strips trailing whitespace from username" do
        user = create(:user, username: "testuser  ")
        expect(user.username).to eq("testuser")
      end

      it "strips both leading and trailing whitespace" do
        user = create(:user, username: "  testuser  ")
        expect(user.username).to eq("testuser")
      end
    end

    describe "#ensure_jti" do
      it "generates a JTI on create" do
        user = create(:user)
        expect(user.jti).to be_present
        expect(user.jti).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
      end

      it "does not override existing JTI" do
        custom_jti = SecureRandom.uuid
        user = build(:user)
        user.jti = custom_jti
        user.save!
        expect(user.jti).to eq(custom_jti)
      end
    end
  end

  describe "instance methods" do
    describe "#regenerate_jti!" do
      it "changes the JTI to a new value" do
        user = create(:user)
        old_jti = user.jti
        user.regenerate_jti!
        expect(user.jti).not_to eq(old_jti)
      end

      it "persists the new JTI" do
        user = create(:user)
        user.regenerate_jti!
        expect(user.reload.jti).to eq(user.jti)
      end
    end

    describe "#revoke_jwt!" do
      it "regenerates the JTI" do
        user = create(:user)
        old_jti = user.jti
        user.revoke_jwt!
        expect(user.jti).not_to eq(old_jti)
      end
    end
  end

  describe "has_secure_password" do
    it "authenticates with correct password" do
      user = create(:user, password: "correctpass", password_confirmation: "correctpass")
      expect(user.authenticate("correctpass")).to eq(user)
    end

    it "rejects incorrect password" do
      user = create(:user, password: "correctpass", password_confirmation: "correctpass")
      expect(user.authenticate("wrongpass")).to be_falsey
    end

    it "stores password as digest" do
      user = create(:user, password: "testpass", password_confirmation: "testpass")
      expect(user.password_digest).to be_present
      expect(user.password_digest).not_to eq("testpass")
    end
  end
end
