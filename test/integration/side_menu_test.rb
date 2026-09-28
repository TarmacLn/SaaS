require "test_helper"

class SideMenuTest < ActionDispatch::IntegrationTest
  test "side menu links to each branch" do
    get root_path

    assert_select "#side-menu #links-list" do
      assert_select "a[href=?]", hobby_posts_path, text: /Find a hobby buddy/
      assert_select "a[href=?]", study_posts_path, text: /Find a study buddy/
      assert_select "a[href=?]", team_posts_path, text: /Find a team member/
    end
  end

  test "guest is asked to log in" do
    get root_path

    assert_select "#side-menu .non-signed-in-message a[href=?]", login_path
  end

  test "signed in user is not asked to log in" do
    sign_in users(:one)
    get root_path

    assert_select "#side-menu .non-signed-in-message", count: 0
  end
end
