require "test_helper"

class PostModalTest < ActionDispatch::IntegrationTest
  test "home page renders the post modal once" do
    get root_path

    assert_select "[data-controller=post-modal] #post-modal.modal", count: 1
  end

  test "each post card opens the modal and carries its full content" do
    get root_path

    Post.limit(5).each do |post|
      assert_select ".single-post-card[id=?][data-action*=?]", post_path(post), "post-modal#open" do
        assert_select ".post-content h3", text: post.title
        assert_select ".post-content p", text: post.content
      end
    end
  end

  test "cards carry the right modal button for who is looking" do
    get root_path
    assert_select ".single-post-card[id=?] .post-actions a[href=?]", post_path(posts(:team_post)), login_path

    sign_in users(:one)
    get root_path
    assert_select ".single-post-card[id=?] .post-actions", post_path(posts(:hobby_post)), text: /This is your post/
    assert_select ".single-post-card[id=?] .post-actions a.interested[href=?]",
                  post_path(posts(:team_post)), post_path(posts(:team_post))
  end
end
