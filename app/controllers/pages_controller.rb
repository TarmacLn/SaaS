class PagesController < ApplicationController
  def index
    @branch = params[:branch].presence_in(Category::BRANCHES)
    @categories = @branch ? Category.where(branch: @branch).order(:id) : Category.none

    posts = PostsForBranchService.new({
      search: params[:search],
      category: params[:category],
      branch: @branch
    }).call
    @pagy, @posts = pagy(:offset, posts.includes(:user, :category).newest_first)
  end
end
