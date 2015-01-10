# Author: Nicolas Meylan
# Date: 21.09.14
# Encoding: UTF-8
# File: preference.rb

class Preference < ActiveRecord::Base
  belongs_to :user
  enum key: {notification_watcher_in_app: 0, notification_watcher_email: 1,
             notification_participant_in_app: 2, notification_participant_email: 3}

  def self.notification_keys
    Preference.keys.keep_if { |k, _| k.to_s.start_with?('notification') }
  end
end