class CreateNotifications < ActiveRecord::Migration
  def up
    create_table :notifications do |t|
      t.integer :notifiable_id
      t.string :notifiable_type
      t.string :notification_type
      t.integer :user_id
      t.integer :project_id
      t.integer :from_id
      t.timestamps :created_at
      t.timestamps :updated_at
    end
  end

  def down
    drop_table :notifications
  end
end
