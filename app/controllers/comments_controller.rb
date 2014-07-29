# Author: Nicolas Meylan
# Date: 27.07.14
# Encoding: UTF-8
# File: comments_controller.rb

class CommentsController < ApplicationController

  def create
    @comment = Comment.new(comment_params)
    @comment.author = current_user
    respond_to do |format|
      if @comment.save
        format.js {respond_to_js action: 'do_nothing',:response_header => :success, :response_content => t(:successful_creation)}
      else
        format.js {respond_to_js action: 'do_nothing',:response_header => :failure, :response_content => "#{t(:failure_creation)} : #{@comment.errors.full_messages.join(', ')}"}
      end
    end
  end

  def show
    @comment = Comment.find_by_id(params[:id])
    @comments = Comment.where(commentable_type: @comment.commentable_type, commentable_id: @comment.commentable_id).decorate(context: {selected_comment: @comment})
    respond_to do |format|
      format.js { respond_to_js action: 'show', locals: {comments: @comments}}
    end
  end

  private
  def comment_params
    params.require(:comment).permit(Comment.permit_attributes)
  end

end