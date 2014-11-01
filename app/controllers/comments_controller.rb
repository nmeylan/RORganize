# Author: Nicolas Meylan
# Date: 27.07.14
# Encoding: UTF-8
# File: comments_controller.rb

class CommentsController < ApplicationController
  before_filter :find_comment, only: [:update, :destroy, :edit, :show]
  before_filter :check_permission, only: [:update, :destroy, :create]
  include Rorganize::RichController

  def create
    @comment = Comment.new(comment_params).decorate
    @comment.project = @project
    @comment.author = User.current
    js_callback(@comment.save, [t(:successful_creation), "#{t(:failure_creation)} : #{@comment.errors.full_messages.join(', ')}"])
  end

  def show
    @comments_decorator = Comment.eager_load(:project).where(commentable_type: @comment.commentable_type, commentable_id: @comment.commentable_id).decorate(context: {selected_comment: @comment})
    respond_to do |format|
      format.js { respond_to_js action: 'show', locals: {comments_decorator: @comments_decorator} }
    end
  end

  def edit
    respond_to do |format|
      format.js { respond_to_js }
    end
  end

  def update
    @comment.update(comment_params)
    simple_js_callback(@comment.save, :update, @comment)
  end

  def destroy
    simple_js_callback(@comment.destroy, :delete, @comment)
  end

  private
  def comment_params
    params.require(:comment).permit(Comment.permit_attributes)
  end

  def find_comment
    @comment = Comment.find_by_id(params[:id])
    if @comment
      @project = @comment.project
    else
      render_404
    end
  end

  def check_permission
    if user_allowed_to_add_comment?
      true
    elsif user_allowed_to_update_this_comment?
      true
    elsif user_allowed_to_destroy_this_comment
      true
    else
      render_403
    end
  end

  def user_allowed_to_destroy_this_comment
    action_name.eql?('destroy') && (User.current.allowed_to?('destroy_comment_not_owner', 'comments', @project) || @comment.author?(User.current))
  end

  def user_allowed_to_update_this_comment?
    action_name.eql?('update') && (User.current.allowed_to?('edit_comment_not_owner', 'comments', @project) || @comment.author?(User.current))
  end

  def user_allowed_to_add_comment?
    action_name.eql?('create') && User.current.allowed_to?('comment', params[:comment][:commentable_type].pluralize, @project)
  end

end