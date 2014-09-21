class InsertNotificationPreferenceEnumerations < ActiveRecord::Migration
  def up
    Enumeration.create(opt: 'PRNO', name: 'notification_watcher_email')
    Enumeration.create(opt: 'PRNO', name: 'notification_watcher_in_app')
    Enumeration.create(opt: 'PRNO', name: 'notification_participant_email')
    Enumeration.create(opt: 'PRNO', name: 'notification_participant_in_app')
  end

  def down
    Enumeration.delete_all(opt: 'PRNO')
  end
end
