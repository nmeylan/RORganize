# Author: Nicolas Meylan
# Date: 20.09.14
# Encoding: UTF-8
# File: notifications_controller.rb

class NotificationsController < ApplicationController
  before_filter :find_user

  def index
    @sessions[:filter_recipient_type] = params[:filter] ? params[:filter] : 'all'
    @sessions[:filter_project] = params[:project] ? params[:project] : 'all'
    filter = @sessions[:filter_recipient_type].eql?('all') ? '1 = 1' : {recipient_type: @sessions[:filter_recipient_type]}
    project = @sessions[:filter_project].eql?('all') ? '1 = 1' : {project_id: @sessions[:filter_project]}

    @notifications_decorator = Notification.includes(:project, :notifiable, :from).where(user_id: @user.id).where(filter).order('notifications.created_at DESC')

    count_participating = Notification.where(user_id: @user.id, recipient_type: 'participants').count('id')
    count_watching = Notification.where(user_id: @user.id, recipient_type: 'watchers').count('id')
    projects = {}
    @notifications_decorator.map(&:project).uniq.each do |project|
      projects[project.slug] = {count: @notifications_decorator.to_a.count { |notif| notif.project_id.eql?(project.id) }, id: project.id}
    end
    filters = {all: count_participating + count_watching, participants: count_participating, watchers: count_watching}

    @notifications_decorator = @notifications_decorator.where(project).decorate(context: {filters: filters, projects: projects})
    respond_to do |format|
      format.html { render :index }
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
    filter = @sessions[:filter_recipient_type].eql?('all') ? '1 = 1' : {recipient_type: @sessions[:filter_recipient_type]}

    notifications = Notification.includes(:notifiable, :project).where(project_id: Project.find_by_slug(params[:project_slug]), user_id: @user.id).where(filter)
    notifications.delete_all
    respond_to do |format|
      format.html { redirect_to action: 'index', filter: @sessions[:filter_recipient_type] }
    end
  end

  private
  def find_user
    @user = User.current
  end

  def notifiable_path(notification)
    if notification.notifiable.is_a? Issue
      issue_path(notification.project.slug, notification.notifiable.id, anchor: "#{notification.trigger_type.downcase}-#{notification.trigger_id}")
    elsif notification.notifiable.is_a? Document
      document_path(notification.project.slug, notification.notifiable.id, anchor: "#{notification.trigger_type.downcase}-#{notification.trigger_id}")
    end
  end
end