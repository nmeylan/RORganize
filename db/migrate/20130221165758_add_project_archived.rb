class AddProjectArchived < ActiveRecord::Migration
  def up
    add_column :projects, :is_archived, :boolean, default: false
    Permission.create(controller: 'Project', action: 'archive', name: 'Archive project', is_locked: true)
  end

  def down
    remove_column :projects, :is_archived
    Permission.delete_all(controller: 'Project', action: 'archive', name: 'Archive project')
  end
end
