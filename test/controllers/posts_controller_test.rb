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

  test "branch pages show only that branch's posts" do
    { hobby: posts(:hobby_post), study: posts(:study_post), team: posts(:team_post) }.each do |branch, post|
      get "/posts/#{branch}"

      assert_response :success
      assert_select ".single-post-card", count: 1
      assert_select ".single-post-card[id=?]", post_path(post)
    end
  end

  test "branch page has a title and the post modal" do
    get hobby_posts_path

    assert_select "h1.page-title", text: "Find a hobby buddy"
    assert_select "[data-controller=post-modal] #post-modal", count: 1
  end
end
