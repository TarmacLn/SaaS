module PostsHelper
  BRANCH_PAGES = {
    "hobby" => {
      title: "Find a hobby buddy",
      search_placeholder: "E.g. guitar playing, programming, cooking"
    },
    "study" => {
      title: "Find a study buddy",
      search_placeholder: "E.g. nutrition, calculus, astrophysics"
    },
    "team" => {
      title: "Find a team member",
      search_placeholder: "E.g. musician for a band, developer for a project"
    }
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
    BRANCH_PAGES.fetch(branch)[:title]
  end

  def branch_search_placeholder(branch)
    BRANCH_PAGES.fetch(branch)[:search_placeholder]
  end

  # /posts/hobby, /posts/study, /posts/team, with optional query params
  def branch_posts_path(branch, **query)
    url_for(controller: "/posts", action: branch, only_path: true, **query.compact_blank)
  end

  def create_new_post_partial_path
    if user_signed_in?
      "posts/branch/create_new_post/signed_in"
    else
      "posts/branch/create_new_post/not_signed_in"
    end
  end

  def all_categories_button_partial_path
    if params[:category].blank?
      "posts/branch/categories/all_selected"
    else
      "posts/branch/categories/all_not_selected"
    end
  end

  def category_field_partial_path
    if params[:category].present?
      "posts/branch/search_form/category_field"
    else
      "shared/empty_partial"
    end
  end

  def no_posts_partial_path(posts)
    posts.empty? ? "posts/shared/no_posts" : "shared/empty_partial"
  end
end
