class DropUselessPermissions < ActiveRecord::Migration
  def up
    Permission.delete_all(controller: 'Projects', action: 'show')
    Permission.delete_all(controller: 'Projects', action: 'rodmap')
    Permission.where(controller: 'Roadmaps', action: 'show').first.update_column(:name, 'View roadmap')
  end

  def down

  end
end
