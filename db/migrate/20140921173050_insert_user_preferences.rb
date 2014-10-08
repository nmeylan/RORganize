class InsertUserPreferences < ActiveRecord::Migration
  def up
    Preference.delete_all
    Preference.transaction do
      User.all.each do |user|
        Preference.notification_keys.each_value do |v|
          Preference.create(user_id: user.id, key: v, boolean_value: true)
        end
      end
    end
  end

  def down
    Preference.delete_all(key: Preference.notification_keys.values)
  end
end
