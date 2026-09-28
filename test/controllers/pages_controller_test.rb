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

  test "home page shows posts from every branch by default" do
    get root_path

    assert_select "#main-content .single-post-card", count: Post.count
    assert_select ".branches-list a.selected-item", text: "All"
  end

  test "home page filters by branch" do
    get root_path(branch: "study")

    assert_select "#main-content .single-post-card", count: 1
    assert_select ".single-post-card[id=?]", post_path(posts(:study_post))
    assert_select ".branches-list a.selected-item", text: "Study"
    assert_select "h1.page-title", text: "Find a study buddy"
  end

  test "home page filters by branch and category" do
    get root_path(branch: "hobby", category: "Sports")

    assert_select ".single-post-card[id=?]", post_path(posts(:hobby_post))
    assert_select ".categories-list a.selected-item", text: "Sports"
    assert_select "#search-form input[type=hidden][name=category][value=Sports]"
  end

  test "home page searches all posts" do
    get root_path(search: "developer")

    assert_select "#main-content .single-post-card", count: 1
    assert_select ".single-post-card[id=?]", post_path(posts(:team_post))
  end

  test "home page ignores an unknown branch" do
    get root_path(branch: "nope")

    assert_response :success
    assert_select "#main-content .single-post-card", count: Post.count
  end

  test "home page shows the create post button to signed in users" do
    sign_in users(:one)
    get root_path(branch: "team")

    assert_select "#main-content a.new-post-button[href=?]", new_post_path(branch: "team")
  end

  test "home page asks guests to log in to create a post" do
    get root_path

    assert_select "#main-content .login-branch a[href=?]", login_path
  end
end
