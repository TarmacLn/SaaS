require "test_helper"

class GoogleLoginTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2", uid: "google-456",
      info: { email: "maria@gmail.com", name: "Maria" },
      extra: { raw_info: { email_verified: true } }
    )
  end

  teardown do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.test_mode = false
  end

  def log_in_with_google
    post user_google_oauth2_omniauth_authorize_path
    follow_redirect! # to the callback (Google, faked by OmniAuth's test mode)
  end

  test "login and signup pages offer Google, as a form POST without Turbo" do
    [ login_path, signup_path ].each do |path|
      get path
      assert_select "form[action=?][method=post] button[data-turbo=false].google-login-button",
                    user_google_oauth2_omniauth_authorize_path
    end
  end

  test "logging in with Google creates the account and signs in" do
    assert_difference "User.count", 1 do
      log_in_with_google
    end
    assert_redirected_to root_path
    follow_redirect!

    assert_select "#user-name", text: "Maria"
    assert_select ".alert", text: /Successfully authenticated from Google account/
  end

  test "logging in again uses the same account" do
    log_in_with_google
    delete destroy_user_session_path

    assert_no_difference "User.count" do
      log_in_with_google
    end
    follow_redirect!
    assert_select "#user-name", text: "Maria"
  end

  test "a cancelled Google login goes back to the login page" do
    OmniAuth.config.mock_auth[:google_oauth2] = :access_denied
    silence_omniauth_logger { log_in_with_google }
    follow_redirect! while response.redirect? && !response.location.end_with?(new_user_session_path)

    assert_redirected_to new_user_session_path
    assert_equal "Google login was cancelled or failed. Please try again.", flash[:alert]
  end

  test "Google users can edit their profile without a password" do
    log_in_with_google
    user = User.find_by!(email: "maria@gmail.com")

    put user_registration_path, params: { user: { name: "Maria K", email: "maria@gmail.com" } }
    assert_equal "Maria K", user.reload.name
  end

  test "the profile page has no password fields for Google-only accounts" do
    log_in_with_google
    get edit_user_registration_path

    assert_select ".google-only-note", text: /log in with Google/
    assert_select "input[type=password]", count: 0
  end

  test "Google-only accounts cannot set a password" do
    log_in_with_google
    user = User.find_by!(email: "maria@gmail.com")

    put user_registration_path, params: { user: { name: "Maria", email: "maria@gmail.com",
                                                  password: "newpassword", password_confirmation: "newpassword" } }
    assert_predicate user.reload.encrypted_password, :blank?
  end

  test "Google-only accounts cannot log in with email and password" do
    log_in_with_google
    delete destroy_user_session_path

    post user_session_path, params: { user: { email: "maria@gmail.com", password: "" } }
    assert_response :unprocessable_entity
  end

  test "a linked account keeps its password fields and still needs the current password" do
    OmniAuth.config.mock_auth[:google_oauth2].info.email = users(:one).email
    log_in_with_google
    get edit_user_registration_path
    assert_select "input[type=password][name='user[current_password]']"

    put user_registration_path, params: { user: { name: "Changed", email: users(:one).email } }
    assert_equal "User One", users(:one).reload.name
  end

  test "other users still need their current password to edit their profile" do
    sign_in users(:one)

    put user_registration_path, params: { user: { name: "Changed", email: users(:one).email } }
    assert_equal "User One", users(:one).reload.name
  end

  private

  def silence_omniauth_logger
    logger = OmniAuth.config.logger
    OmniAuth.config.logger = Logger.new(IO::NULL)
    yield
  ensure
    OmniAuth.config.logger = logger
  end
end
