class AddDeletedAtToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :deleted_at, :timestamp
  end
end
