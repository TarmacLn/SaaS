module PagesHelper
  # The home page renders post cards (posts/_post), which use PostsHelper
  include PostsHelper

  # Home page URL with the given filters, dropping empty ones
  def home_filter_path(**filters)
    root_path(filters.compact_blank)
  end

  def home_page_title
    @branch ? branch_page_title(@branch) : "Latest posts"
  end
end
