require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home page loads for a guest" do
    get root_path
    assert_response :success
  end

  test "home page loads for a signed in user" do
    sign_in users(:one)
    get root_path
    assert_response :success
  end
end
