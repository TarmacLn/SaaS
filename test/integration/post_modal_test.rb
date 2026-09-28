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
end
