class PostsController < ApplicationController
  def show
    @post = Post.includes(:user, :category).find(params[:id])
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

  def posts_for_branch(branch)
    @branch = branch
    @posts = Post.by_branch(branch).includes(:user, :category).order(created_at: :desc)
    render :branch
  end
end
