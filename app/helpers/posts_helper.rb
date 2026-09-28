module PostsHelper
  BRANCH_PAGE_TITLES = {
    "hobby" => "Find a hobby buddy",
    "study" => "Find a study buddy",
    "team" => "Find a team member"
  }.freeze

  def post_author_initial(post)
    post.user.name.to_s.strip.first&.upcase || "?"
  end

  def contact_button_partial_path
    if user_signed_in?
      "posts/contact_button/signed_in"
    else
      "posts/contact_button/guest"
    end
  end

  def branch_page_title(branch)
    BRANCH_PAGE_TITLES.fetch(branch)
  end
end
