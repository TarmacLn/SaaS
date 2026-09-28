class PostsForBranchService
  def initialize(params)
    @search = params[:search]
    @category = params[:category]
    @branch = params[:branch]
  end

  # get posts depending on the request; without a branch, posts from every branch
  def call
    posts =
      if @branch.blank?
        Post.all
      elsif @category.present?
        Post.by_category(@branch, @category)
      else
        Post.by_branch(@branch)
      end
    posts = posts.search(@search) if @search.present?
    posts
  end
end
