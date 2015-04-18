# Author: Nicolas Meylan
# Date: 20.09.14
# Encoding: UTF-8
# File: notifiable.rb

module Notifiable
  extend ActiveSupport::Concern
  included do |base|
    has_many :notifications, -> { where(notifiable_type: base) }, as: :notifiable, dependent: :delete_all
  end

  class << self
    def bulk_delete_dependent(notifiable_ids, class_name)
      Notification.delete_all(notifiable_id: notifiable_ids, notifiable_type: class_name)
    end
  end
end