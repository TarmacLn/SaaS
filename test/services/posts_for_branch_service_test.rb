require "test_helper"

class PostsForBranchServiceTest < ActiveSupport::TestCase
  def posts_for(**params)
    PostsForBranchService.new(params).call.to_a
  end

  test "returns all posts in the branch" do
    assert_equal [ posts(:hobby_post) ], posts_for(branch: "hobby")
  end

  test "filters by category" do
    assert_equal [ posts(:study_post) ], posts_for(branch: "study", category: "Computer Science")
    assert_empty posts_for(branch: "study", category: "Sports")
  end

  test "filters by search" do
    assert_equal [ posts(:study_post) ], posts_for(branch: "study", search: "algorithms")
    assert_empty posts_for(branch: "study", search: "tennis")
  end

  test "filters by category and search together" do
    assert_equal [ posts(:team_post) ], posts_for(branch: "team", category: "Development", search: "Rails")
    assert_empty posts_for(branch: "team", category: "Development", search: "tennis")
  end

  test "without a branch returns posts from every branch" do
    assert_equal Post.count, posts_for.size
    assert_equal [ posts(:hobby_post) ], posts_for(search: "tennis")
  end

  test "ignores the category without a branch" do
    assert_equal Post.count, posts_for(category: "Sports").size
  end
end
