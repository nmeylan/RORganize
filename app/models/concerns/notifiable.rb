# Author: Nicolas Meylan
# Date: 20.09.14
# Encoding: UTF-8
# File: notifiable.rb

module Notifiable
  extend ActiveSupport::Concern
  included do |base|
    has_many :notifications, -> { where(notifiable_type: base) }, as: :notifiable
    after_destroy :delete_all_notifications
  end

  def delete_all_notifications
    Notification.unscoped do
      Notification.delete_all(notifiable_type: self.class, notifiable_id: self.id)
    end
  end

  class << self
    def bulk_delete_dependent(notifiable_ids, class_name)
      Notification.unscoped.delete_all(notifiable_id: notifiable_ids, notifiable_type: class_name)
    end
  end
end