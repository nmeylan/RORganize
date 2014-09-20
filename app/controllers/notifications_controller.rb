# Author: Nicolas Meylan
# Date: 20.09.14
# Encoding: UTF-8
# File: notifications_controller.rb

class NotificationsController < ApplicationController
  before_filter :find_user

  def index
    @notifications_decorator = Notification.includes(:project, :notifiable, :from).where(user_id: @user.id).order('notifications.created_at DESC').decorate
    respond_to do |format|
      format.html {render action: 'index'}
    end
  end

  def destroy
    notification = Notification.includes(:notifiable, :project).find_by_id(params[:id])
    if notification.user_id.eql?(@user.id)
      path = notifiable_path(notification)
      notification.destroy
      respond_to do |format|
        format.html { redirect_to path }
      end
    end
  end

  def destroy_all_for_project
    notifications = Notification.includes(:notifiable, :project).where(project_id: Project.find_by_slug(params[:project_slug]), user_id: @user.id)
    notifications.destroy_all
    respond_to do |format|
      format.html {redirect_to action: 'index'}
    end
  end

  private
  def find_user
    @user = User.current
  end

  def notifiable_path(notification)
    if notification.notifiable.is_a? Issue
      issue_path(notification.project.slug, notification.notifiable.id)
    elsif notification.notifiable.is_a? Document
      document_path(notification.project.slug, notification.notifiable.id)
    end
  end
end