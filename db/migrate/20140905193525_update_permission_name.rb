class UpdatePermissionName < ActiveRecord::Migration
  def up
    Permission.where(controller: 'Settings', action: 'modules').first.update_column(:name, 'Manage modules')
  end
end
