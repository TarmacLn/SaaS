class PostsController < ApplicationController
  def show
    @post = Post.includes(:user, :category).find(params[:id])
  end
end
