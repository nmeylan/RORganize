# Author: Nicolas Meylan
# Date: 27.07.14
# Encoding: UTF-8
# File: comments_controller.rb

class CommentsController < ApplicationController
  before_filter :find_comment, :only => [:update, :destroy, :edit, :show]
  before_filter :check_permission, :only => [:update, :destroy, :create]

  def create
    @comment = Comment.new(comment_params)
    @comment.project = @project
    @comment.author = User.current
    respond_to do |format|
      if @comment.save
        @comment = @comment.decorate
        format.js { respond_to_js :response_header => :success, :response_content => t(:successful_creation) }
      else
        format.js { respond_to_js action: 'do_nothing', :response_header => :failure, :response_content => "#{t(:failure_creation)} : #{@comment.errors.full_messages.join(', ')}" }
      end
    end
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
    respond_to do |format|
      if @comment.save
          format.js { respond_to_js :response_header => :success, :response_content => t(:successful_update) }
      else
        format.js { respond_to_js action: 'do_nothing', :response_header => :failure, :response_content => t(:failure_update) }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @comment.destroy
        format.js { respond_to_js :response_header => :success, :response_content => t(:successful_deletion) }
      else
        format.js { respond_to_js action: 'do_nothing', :response_header => :failure, :response_content => t(:failure_deletion) }
      end
    end
  end

  private
  def comment_params
    params.require(:comment).permit(Comment.permit_attributes)
  end

  def find_comment
    @comment = Comment.find_by_id(params[:id])
    @project = @comment.project
    unless @comment
      render_404
    end
  end

  def check_permission
    if action_name.eql?('create') && User.current.allowed_to?('comment', params[:comment][:commentable_type].pluralize, @project)
      true
    elsif action_name.eql?('update') && (User.current.allowed_to?('edit_comment_not_owner', 'comments', @project) || @comment.author?(User.current))
      true
    elsif action_name.eql?('destroy') && (User.current.allowed_to?('destroy_comment_not_owner', 'comments', @project) || @comment.author?(User.current))
      true
    else
      render_403
    end
  end

end