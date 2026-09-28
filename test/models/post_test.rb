require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "belongs to a user" do
    assert_equal users(:one), posts(:hobby_post).user
  end

  test "belongs to a category" do
    assert_equal categories(:sports), posts(:hobby_post).category
  end

  test "is invalid without a user" do
    post = Post.new(title: "No user", category: categories(:sports))
    assert_not post.valid?
    assert post.errors.added?(:user, :blank)
  end

  test "is invalid without a category" do
    post = Post.new(title: "No category", user: users(:one))
    assert_not post.valid?
    assert post.errors.added?(:category, :blank)
  end

  test "is valid with a user and a category" do
    post = Post.new(title: "Complete", user: users(:one), category: categories(:sports))
    assert post.valid?
  end

  test "by_branch returns only posts in that branch" do
    assert_equal [ posts(:study_post) ], Post.by_branch("study").to_a
    assert_equal [ posts(:hobby_post) ], Post.by_branch("hobby").to_a
  end
end
