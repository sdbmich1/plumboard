class PostsController < ApplicationController
  before_filter :authenticate_user!

  def index
  end

  def show
  end

  def create
    @listing = Listing.find_by_pixi_id params[:post][:pixi_id]
    @post = Post.new params[:post]
    if @post.save
      flash[:notice] = "Successfully created post."
      @posts = Post.load_new @listing
    end
  end

  def destroy
  end
end
