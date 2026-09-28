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

  test "guest is asked to log in to contact the author" do
    get post_path(posts(:hobby_post))

    assert_select ".contact-user.login-required a[href=?]", login_path
    assert_select ".message-form", count: 0
  end

  test "signed in user sees the message form on someone else's post" do
    sign_in User.create!(name: "Visitor", email: "visitor@example.com", password: "password")
    get post_path(posts(:study_post))

    assert_select "#contact-user form.message-form[action=?]", private_conversations_path do
      assert_select "input[type=hidden][name=post_id][value=?]", posts(:study_post).id.to_s
      assert_select "textarea[name=message_body]"
    end
  end

  test "author sees no contact section on their own post" do
    sign_in users(:one)
    get post_path(posts(:hobby_post))

    assert_select ".contact-user", count: 0
  end

  test "user already in touch with the author sees a note instead of the form" do
    # users one and two already have a conversation (fixtures)
    sign_in users(:one)
    get post_path(posts(:team_post))

    assert_select ".contacted-user", text: /already in touch/
    assert_select ".message-form", count: 0
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

  test "branch page filters by category and search" do
    get team_posts_path(category: "Development", search: "rails")

    assert_select ".single-post-card[id=?]", post_path(posts(:team_post))
    assert_select ".categories-list a.selected-item", text: "Development"
    assert_select "#search-form input[name=search][value=rails]"
    assert_select "#search-form input[type=hidden][name=category][value=Development]"
  end

  test "branch page shows a message when nothing matches" do
    get hobby_posts_path(search: "nothing matches this")

    assert_select ".single-post-card", count: 0
    assert_select ".no-posts", text: /no published posts/
  end

  test "guest is asked to log in to create a post" do
    get hobby_posts_path

    assert_select ".login-branch a[href=?]", login_path
    assert_select ".new-post-button", count: 0
  end

  test "signed in user can open the new post form for a branch" do
    sign_in users(:one)
    get hobby_posts_path
    assert_select "a.new-post-button[href=?]", new_post_path(branch: "hobby")

    get new_post_path(branch: "hobby")
    assert_response :success
    assert_select "select[name=?] option", "post[category_id]", count: 1, text: "Sports"
  end

  test "new post form lists every category without a branch" do
    sign_in users(:one)
    get new_post_path

    assert_select "select[name=?] optgroup option", "post[category_id]", count: Category.count
  end

  test "guest cannot open the new post form" do
    get new_post_path(branch: "hobby")
    assert_redirected_to new_user_session_path
  end

  test "guest cannot create a post" do
    assert_no_difference "Post.count" do
      post posts_path, params: { post: { title: "Hello there", content: "x" * 30, category_id: categories(:sports).id } }
    end
    assert_redirected_to new_user_session_path
  end

  test "signed in user creates a post" do
    sign_in users(:two)

    assert_difference "Post.count", 1 do
      post posts_path, params: { branch: "hobby", post: {
        title: "Chess partner wanted", content: "Looking for someone to play chess with.",
        category_id: categories(:sports).id
      } }
    end

    new_post = Post.order(:created_at).last
    assert_equal users(:two), new_post.user
    assert_redirected_to post_path(new_post)
    follow_redirect!
    assert_select ".alert", text: /published/
  end

  test "invalid post re-renders the form with errors" do
    sign_in users(:two)

    assert_no_difference "Post.count" do
      post posts_path, params: { branch: "hobby", post: { title: "Hi", content: "short", category_id: categories(:sports).id } }
    end

    assert_response :unprocessable_entity
    assert_select ".invalid-feedback", minimum: 2
    assert_select "input[type=hidden][name=branch][value=hobby]"
  end

  test "user_id in params is ignored" do
    sign_in users(:two)
    post posts_path, params: { post: {
      title: "Not my post", content: "Trying to post as someone else here.",
      category_id: categories(:sports).id, user_id: users(:one).id
    } }

    assert_equal users(:two), Post.order(:created_at).last.user
  end
end
