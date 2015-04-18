# Author: Nicolas Meylan
# Date: 20.09.14
# Encoding: UTF-8
# File: notification.rb

class Notification < ActiveRecord::Base
  include SoftDeletable
  RECIPIENT_TYPE_WATCHER = 'watchers'
  RECIPIENT_TYPE_PARTICIPANT = 'participants'
  belongs_to :user
  belongs_to :from, class_name: 'User'
  belongs_to :project
  belongs_to :notifiable, polymorphic: true

  after_create :make_uniq

  # Delete all notification from the same notifiable and for the same user.
  def make_uniq
    Notification.where.not(id: self.id).delete_all(user_id: self.user_id,
                                                   notifiable_id: self.notifiable_id,
                                                   notifiable_type: self.notifiable_type)
  end

  # This method loads Notifications, prepare filters (per project and per recipient type) for a given user.
  # @param [Hash|String] condition : a condition clause e.g : {recipient_type: 'watchers'}.
  # if no restriction then give to the method '1=1'.
  # @param [String] project_condition : a condition clause for the project e.g : {project_id: 1}
  # if no restriction then give to the method '1=1'.
  # @param [User] user : the user for who notifications should be loaded.
  # @return [Array] an array of length 3.
  # 'First' index : 'Array' loaded Notifications (an array of activerecords)
  # 'Second' index : 'Hash' that contains filters with this structure :
  #  {all: total_notification_count, participants: total_notification_for_participant_type, watchers: same but for watchers}
  # 'Third' index : 'Hash' with following structure
  # { project_slug => { count: number_notification, id: project_id } }
  def self.filter_notifications(condition, project_condition, user)
    notifications = Notification.includes(:project, :notifiable, :from)
                        .where(user_id: user.id)
                        .where(condition)
                        .order('notifications.created_at DESC')
    notifications = notifications.unscoped if condition.eql?("1 = 1")
    count_participating, count_watching = count_notification_by_recipient_type(user)
    projects = count_notifications_by_projects(notifications)
    filters = {all: count_participating + count_watching, participants: count_participating, watchers: count_watching}

    return notifications.where(project_condition), filters, projects
  end

  # @param [Array] notifications : an array containing notifications.
  # @return [Hash] a Hash with the following structure :
  # { project_slug => { count: number_notification, id: project_id } }
  def self.count_notifications_by_projects(notifications)
    projects = {}
    notifications.map(&:project).uniq.each do |notification_project|
      projects[notification_project.slug] = {count: notifications.to_a.count { |notif| notif.project_id.eql?(notification_project.id) },
                                             id: notification_project.id}
    end
    projects
  end

  # @param [User] user : the user for who we should count notifications.
  # @return [Array] an array of length 2.
  # First index : count for participating notifications.
  # Second index : count for watching notifications.
  def self.count_notification_by_recipient_type(user)
    count_participating = Notification.where(user_id: user.id, recipient_type: 'participants').count('id')
    count_watching = Notification.where(user_id: user.id, recipient_type: 'watchers').count('id')
    return count_participating, count_watching
  end
end