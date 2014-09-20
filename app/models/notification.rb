# Author: Nicolas Meylan
# Date: 20.09.14
# Encoding: UTF-8
# File: notification.rb

class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :from, class_name: 'User'
  belongs_to :project
  belongs_to :notifiable, polymorphic: true

  after_create :make_uniq

  # Delete all notification from the same notifiable and for the same user.
  def make_uniq
    Notification.where.not(id: self.id).delete_all(user_id: self.user_id, notifiable_id: self.notifiable_id, notifiable_type: self.notifiable_type)
  end
end