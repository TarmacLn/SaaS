module PostsHelper
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
end
