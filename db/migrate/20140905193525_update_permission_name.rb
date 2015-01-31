class UpdatePermissionName < ActiveRecord::Migration
  def up
    permission_to_rename = Permission.where(controller: 'Settings', action: 'modules').first
    permission_to_rename.update_column(:name, 'Manage modules') unless permission_to_rename.nil?
  end
end
