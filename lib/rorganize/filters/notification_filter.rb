# Author: Nicolas Meylan
# Date: 25.09.14
# Encoding: UTF-8
# File: notification_filter.rb

module Rorganize
  module Filters
    module NotificationFilter
      def self.included(base)
        base.before_filter :remove_related_notification, only:[:show, :edit]
      end

      def remove_related_notification
        Notification.delete_all(user_id: User.current.id, notifiable_id: params[:id], notifiable_type: controller_name.classify)
      end
    end
  end
end