class PostsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create ]

  def show
    @post = Post.includes(:user, :category).find(params[:id])
    if user_signed_in?
      @message_has_been_sent = conversation_exist?
    end
  end

  def new
    @post = current_user.posts.build
    set_branch_categories
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to post_path(@post), notice: "Your post has been published."
    else
      set_branch_categories
      render :new, status: :unprocessable_entity
    end
  end

  def hobby
    posts_for_branch(params[:action])
  end

  def study
    posts_for_branch(params[:action])
  end

  def team
    posts_for_branch(params[:action])
  end

  private

  def conversation_exist?
    Private::Conversation.between_users(current_user.id, @post.user.id).present?
  end

  def post_params
    params.require(:post).permit(:title, :content, :category_id)
  end

  # Categories offered in the new post form: the branch's own, or all of them
  def set_branch_categories
    @branch = params[:branch] if Category::BRANCHES.include?(params[:branch])
    @categories = @branch ? Category.where(branch: @branch) : Category.order(:branch)
    @categories = @categories.order(:id)
  end

  def posts_for_branch(branch)
    @branch = branch
    @categories = Category.where(branch: branch).order(:id)
    @pagy, @posts = pagy(:offset, get_posts.includes(:user, :category).newest_first)
    render :branch
  end

  def get_posts
    PostsForBranchService.new({
      search: params[:search],
      category: params[:category],
      branch: params[:action]
    }).call
  end
end
