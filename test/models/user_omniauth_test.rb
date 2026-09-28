require "test_helper"

class UserOmniauthTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  def google_auth(uid: "google-123", email: "new.person@gmail.com", name: "New Person", verified: true)
    OmniAuth::AuthHash.new(
      provider: "google_oauth2", uid: uid,
      info: { email: email, name: name },
      extra: { raw_info: { email_verified: verified } }
    )
  end

  test "creates a new user from a Google login" do
    user = nil
    assert_difference "User.count", 1 do
      user = User.from_omniauth(google_auth)
    end

    assert user.persisted?
    assert_equal [ "google_oauth2", "google-123" ], [ user.provider, user.uid ]
    assert_equal "new.person@gmail.com", user.email
    assert_equal "New Person", user.name
    assert user.google_account?
    assert user.google_only?
    assert_predicate user.encrypted_password, :blank?, "no password at all"
  end

  test "returns the same user on their next Google login" do
    first = User.from_omniauth(google_auth)

    assert_no_difference "User.count" do
      assert_equal first, User.from_omniauth(google_auth(email: "changed@gmail.com"))
    end
  end

  test "links Google to an existing account with the same verified email" do
    assert_no_difference "User.count" do
      user = User.from_omniauth(google_auth(email: users(:one).email.upcase))
      assert_equal users(:one), user
    end
    assert_equal [ "google_oauth2", "google-123" ], users(:one).reload.slice(:provider, :uid).values
  end

  test "does not link an account when Google hasn't verified the email" do
    user = User.from_omniauth(google_auth(email: users(:one).email, verified: false))

    assert_not user.persisted?, "the email is taken, so no account is created either"
    assert_nil users(:one).reload.provider
  end

  test "uses the start of the email as the name when Google has none" do
    assert_equal "new.person", User.from_omniauth(google_auth(name: "")).name
  end

  test "normal accounts are not Google accounts" do
    assert_not users(:one).google_account?
    assert_not users(:one).google_only?
  end

  test "a linked account keeps its password" do
    user = User.from_omniauth(google_auth(email: users(:one).email))

    assert user.google_account?
    assert_not user.google_only?
    assert user.valid_password?("password")
  end

  test "a Google-only account can't log in with a password" do
    user = User.from_omniauth(google_auth)

    assert_not user.valid_password?("")
    assert_not user.valid_password?("anything")
  end

  test "a Google-only account gets no reset password email" do
    user = User.from_omniauth(google_auth)

    assert_no_emails { user.send_reset_password_instructions }
    assert_nil user.reload.reset_password_token
  end

  test "a Google-only account stays valid without a password when edited" do
    user = User.from_omniauth(google_auth)
    assert user.update(name: "Renamed")
  end
end
