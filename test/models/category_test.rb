require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "has many posts" do
    assert_equal [ posts(:hobby_post) ], categories(:sports).posts.to_a
  end

  test "cannot be deleted while it has posts" do
    assert_raises(ActiveRecord::InvalidForeignKey) do
      categories(:sports).destroy
    end
  end
end
