class PagesController < ApplicationController
  def index
    @posts = Post.includes(:user, :category).limit(5)
  end
end
