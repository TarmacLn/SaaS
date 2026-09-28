require "test_helper"

class NavigationTest < ActionDispatch::IntegrationTest
  test "guest sees login and signup links" do
    get root_path

    assert_select "nav a[href=?]", login_path, text: "Login"
    assert_select "nav a[href=?]", signup_path, text: "Signup"
    assert_select "#user-settings", count: 0
  end

  test "signed in user sees their name and account links" do
    sign_in users(:one)
    get root_path

    assert_select "#user-name", text: users(:one).name
    assert_select "nav a[href=?]", edit_user_registration_path, text: "Edit Profile"
    assert_select "nav a[href=?][data-turbo-method=delete]", destroy_user_session_path, text: "Log out"
    assert_select "nav a[href=?]", login_path, count: 0
  end

  test "log out signs the user out" do
    sign_in users(:one)
    delete destroy_user_session_path
    follow_redirect!

    assert_select "nav a[href=?]", login_path, text: "Login"
    assert_select "#user-settings", count: 0
  end
end
