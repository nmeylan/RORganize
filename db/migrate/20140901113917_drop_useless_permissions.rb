class DropUselessPermissions < ActiveRecord::Migration
  def up
    Permission.delete_all(controller: 'Projects', action: 'show')
    Permission.delete_all(controller: 'Projects', action: 'rodmap')
    permission_to_rename = Permission.where(controller: 'Roadmaps', action: 'show').first
    permission_to_rename.update_column(:name, 'View roadmap') unless permission_to_rename.nil?
  end

  def down

  end
end
