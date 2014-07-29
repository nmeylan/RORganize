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

  private
  def comment_params
    params.require(:comment).permit(Comment.permit_attributes)
  end

end