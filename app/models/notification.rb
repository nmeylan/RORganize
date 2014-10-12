# Author: Nicolas Meylan
# Date: 20.09.14
# Encoding: UTF-8
# File: notification.rb

class Notification < ActiveRecord::Base
  RECIPIENT_TYPE_WATCHER = 'watchers'
  RECIPIENT_TYPE_PARTICIPANT = 'participants'
  belongs_to :user
  belongs_to :from, class_name: 'User'
  belongs_to :project
  belongs_to :notifiable, polymorphic: true

  after_create :make_uniq

  # Delete all notification from the same notifiable and for the same user.
  def make_uniq
    Notification.where.not(id: self.id).delete_all(user_id: self.user_id, notifiable_id: self.notifiable_id, notifiable_type: self.notifiable_type)
  end

  def self.filter_notifications(filter, project, user)
    notifications = Notification.includes(:project, :notifiable, :from).where(user_id: user.id).where(filter).order('notifications.created_at DESC')

    count_participating, count_watching = count_notification_by_recipient_type(user)
    projects = {}
    count_notifications_by_projects(notifications, projects)
    filters = {all: count_participating + count_watching, participants: count_participating, watchers: count_watching}

    return notifications.where(project), filters, projects
  end

  def self.count_notifications_by_projects(notifications, projects)
    notifications.map(&:project).uniq.each do |notification_project|
      projects[notification_project.slug] = {count: notifications.to_a.count { |notif| notif.project_id.eql?(notification_project.id) }, id: notification_project.id}
    end
  end

  def self.count_notification_by_recipient_type(user)
    count_participating = Notification.where(user_id: user.id, recipient_type: 'participants').count('id')
    count_watching = Notification.where(user_id: user.id, recipient_type: 'watchers').count('id')
    return count_participating, count_watching
  end
end