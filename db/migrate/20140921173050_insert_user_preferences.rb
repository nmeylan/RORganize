class InsertUserPreferences < ActiveRecord::Migration
  def up
    enum_watch_email = Enumeration.find_by_name('notification_watcher_email').id
    enum_watch_in_app = Enumeration.find_by_name('notification_watcher_in_app').id
    enum_participate_email = Enumeration.find_by_name('notification_participant_email').id
    enum_participate_in_app = Enumeration.find_by_name('notification_participant_in_app').id
    Preference.delete_all
    Preference.transaction do
      User.all.each do |user|
        Preference.create(user_id: user.id, enumeration_id: enum_watch_email, boolean_value: true)
        Preference.create(user_id: user.id, enumeration_id: enum_watch_in_app, boolean_value: true)
        Preference.create(user_id: user.id, enumeration_id: enum_participate_email, boolean_value: true)
        Preference.create(user_id: user.id, enumeration_id: enum_participate_in_app, boolean_value: true)
      end
    end
  end
  def down
    Preference.delete_all
  end
end
