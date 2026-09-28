require "test_helper"

class PaginationTest < ActionDispatch::IntegrationTest
  PER_PAGE = Pagy::OPTIONS[:limit]

  setup do
    # Enough hobby posts for two pages, all created at the same moment
    now = Time.current
    PER_PAGE.times do |i|
      Post.create!(title: "Extra hobby post #{i}", content: "Content long enough for a post #{i}.",
                   user: users(:one), category: categories(:sports), created_at: now, updated_at: now)
    end
  end

  def card_ids
    css_select(".single-post-card").map { |card| card["id"] }
  end

  test "home page shows one page of posts and links to the next" do
    get root_path

    assert_equal PER_PAGE, card_ids.size
    assert_select ".pagination-bar .pagination a[href=?]", root_path(page: 2)
    assert_select ".pagination-bar .pagy.info", text: /1-#{PER_PAGE} of #{Post.count}/
  end

  test "pages do not overlap and together contain every post" do
    get root_path
    first_page = card_ids
    get root_path(page: 2)
    second_page = card_ids

    assert_empty first_page & second_page
    assert_equal Post.count, (first_page + second_page).size
  end

  test "page links keep the filters" do
    get root_path(branch: "hobby", category: "Sports")

    assert_select ".pagination-bar a[href=?]", root_path(branch: "hobby", category: "Sports", page: 2)
  end

  test "branch pages are paginated too" do
    get hobby_posts_path
    assert_equal PER_PAGE, card_ids.size
    assert_select ".pagination-bar a[href=?]", hobby_posts_path(page: 2)

    get hobby_posts_path(page: 2)
    assert_equal Post.by_branch("hobby").count - PER_PAGE, card_ids.size
  end

  test "no pagination when everything fits on one page" do
    get study_posts_path

    assert_select ".pagination-bar", count: 0
  end

  test "a page past the end shows no posts instead of an error" do
    get root_path(page: 99)

    assert_response :success
    assert_select ".single-post-card", count: 0
    assert_select ".no-posts"
  end
end
