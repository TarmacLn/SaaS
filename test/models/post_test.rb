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
    post = Post.new(title: "Complete", content: "Long enough content for a post.",
                    user: users(:one), category: categories(:sports))
    assert post.valid?
  end

  test "by_branch returns only posts in that branch" do
    assert_equal [ posts(:study_post) ], Post.by_branch("study").to_a
    assert_equal [ posts(:hobby_post) ], Post.by_branch("hobby").to_a
  end

  test "requires a title of 5 to 255 characters" do
    assert_not Post.new(title: "abcd").tap(&:valid?).errors[:title].empty?
    assert_not Post.new(title: "a" * 256).tap(&:valid?).errors[:title].empty?
    assert Post.new(title: "abcde").tap(&:valid?).errors[:title].empty?
  end

  test "requires content of 20 to 1000 characters" do
    assert_not Post.new(content: "a" * 19).tap(&:valid?).errors[:content].empty?
    assert_not Post.new(content: "a" * 1001).tap(&:valid?).errors[:content].empty?
    assert Post.new(content: "a" * 20).tap(&:valid?).errors[:content].empty?
  end

  test "by_category returns posts in that branch's category" do
    assert_equal [ posts(:hobby_post) ], Post.by_category("hobby", "Sports").to_a
    assert_empty Post.by_category("study", "Sports")
  end

  test "search matches title or content, case insensitive" do
    assert_equal [ posts(:hobby_post) ], Post.search("TENNIS").to_a
    assert_equal [ posts(:team_post) ], Post.search("backend developer").to_a
  end

  test "search treats % and _ literally" do
    assert_empty Post.search("%")
  end

  test "newest_first orders by creation time, then id" do
    now = Time.current
    older = Post.create!(title: "Older post", content: "Content long enough here.", user: users(:one),
                         category: categories(:sports), created_at: now - 1.hour)
    tie_a = Post.create!(title: "Tie post A", content: "Content long enough here.", user: users(:one),
                         category: categories(:sports), created_at: now)
    tie_b = Post.create!(title: "Tie post B", content: "Content long enough here.", user: users(:one),
                         category: categories(:sports), created_at: now)

    ordered = Post.where(id: [ older, tie_a, tie_b ]).newest_first.to_a
    assert_equal [ tie_b, tie_a, older ], ordered
  end
end
