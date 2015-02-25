class CreateNotifications < ActiveRecord::Migration
  def up
    create_table :notifications do |t|
      t.integer :notifiable_id
      t.string :notifiable_type
      t.integer :user_id
      t.integer :project_id
      t.integer :from_id
      t.integer :trigger_id
      t.string :trigger_type
      t.string :recipient_type
      t.timestamps null: false
    end
  end

  def down
    drop_table :notifications
  end
end
