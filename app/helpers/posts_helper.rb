module PostsHelper
  def post_author_initial(post)
    post.user.name.to_s.strip.first&.upcase || "?"
  end
end
