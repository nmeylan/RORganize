# Author: Nicolas Meylan
# Date: 27.07.14
# Encoding: UTF-8
# File: comments_controller.rb

class CommentsController < ApplicationController
  include RichController

  before_action :find_comment, except: [:create]
  before_action :check_permission, only: [:update, :destroy, :create]

  def create
    @comment = Comment.new(comment_params).decorate
    @comment.project = @project
    @comment.author = User.current
    success = @comment.save
    js_callback(success, [t(:successful_creation), "#{t(:failure_creation)} : #{@comment.errors.full_messages.join(', ')}"],
                status: success, comment_block: success ? view_context.comment_block_render(@comment, nil, false) : '')
  end

  def show
    @comments_decorator = Comment.eager_load(:project)
                              .where(commentable_type: @comment.commentable_type, commentable_id: @comment.commentable_id)
                              .decorate(context: {selected_comment: @comment})
    render partial: "comments/comments_modal"
  end

  def edit
    render json: {html: view_context.put_comment_form(@comment), id: @comment.id}
  end

  def update
    simple_js_callback(@comment.update(comment_params), :update, @comment, html: view_context.markdown_to_html(@comment.content, @comment), id: @comment.id)
  end

  def destroy
    simple_js_callback(@comment.destroy, :delete, @comment, id: @comment.id)
  end

  private
  def comment_params
    params.require(:comment).permit(Comment.permit_attributes)
  end

  def find_comment
    @comment = Comment.find(params[:id])
    @project = @comment.project
  end

  def check_permission
    unless user_allowed_to_add_comment? || user_allowed_to_update_this_comment? || user_allowed_to_destroy_this_comment
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
    if action_name.eql?('create')
      ctrl_name = Rorganize::Utils::class_name_to_controller_name(params[:comment][:commentable_type])
      params[:comment][:commentable_type].constantize.find_by!(id: params[:comment][:commentable_id], project_id: @project.id)
      User.current.allowed_to?('comment', ctrl_name, @project)
    else
      false
    end
  end

end