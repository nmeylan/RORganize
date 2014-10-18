class AddRoleLockAttribute < ActiveRecord::Migration
  def change
    add_column :roles, :is_locked, :boolean, default: false
    Role.find_by_name('Non member').update_column(:is_locked, true)
    Role.find_by_name('Anonymous').update_column(:is_locked, true)
  end
end
