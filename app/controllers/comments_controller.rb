class CommentsController < ApplicationController
  def create
    @comment = Comment.new(params[:comment])
    @comment.save

    redirect_to @comment.post
  end
end