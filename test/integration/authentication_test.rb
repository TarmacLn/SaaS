require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "login and signup pages load" do
    get login_path
    assert_response :success

    get signup_path
    assert_response :success
  end

  test "a visitor can sign up and is signed in" do
    assert_difference "User.count", 1 do
      post user_registration_path, params: { user: {
        name: "New User", email: "new@example.com",
        password: "password", password_confirmation: "password"
      } }
    end
    follow_redirect!

    assert_select "#user-name", text: "New User"
  end

  test "signup saves the name" do
    post user_registration_path, params: { user: {
      name: "Named User", email: "named@example.com",
      password: "password", password_confirmation: "password"
    } }

    assert_equal "Named User", User.find_by(email: "named@example.com").name
  end

  test "a user can log in with the right password" do
    post user_session_path, params: { user: { email: users(:one).email, password: "password" } }
    follow_redirect!

    assert_select "#user-name", text: users(:one).name
  end

  test "a user cannot log in with the wrong password" do
    post user_session_path, params: { user: { email: users(:one).email, password: "wrong" } }

    assert_response :unprocessable_entity
    assert_select "#user-settings", count: 0
  end
end
