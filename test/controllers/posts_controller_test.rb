require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "shows a post on its own page" do
    post = posts(:hobby_post)
    get post_path(post)

    assert_response :success
    assert_select "h3", text: post.title
    assert_select ".posted-by", text: /#{post.user.name}/
    assert_select ".post-category", text: post.category.name
  end

  test "guest sees a log in button instead of contacting" do
    get post_path(posts(:hobby_post))

    assert_select "a[href=?]", login_path, text: "Log in to contact"
    assert_select ".interested", count: 0
  end

  test "signed in user sees the interested button" do
    sign_in users(:two)
    get post_path(posts(:hobby_post))

    assert_select ".interested", text: /I'm interested/
  end

  test "returns 404 for a missing post" do
    get post_path(id: 0)
    assert_response :not_found
  end
end
