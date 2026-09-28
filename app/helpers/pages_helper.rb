module PagesHelper
  # The home page renders post cards (posts/_post), which use PostsHelper
  include PostsHelper

  def login_required_partial_path
    user_signed_in? ? "shared/empty_partial" : "pages/index/login_required"
  end
end
