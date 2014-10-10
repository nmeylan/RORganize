class AddVersionsPosition < ActiveRecord::Migration
  def up
    add_column :versions, :position, :integer
    Permission.create(controller: 'Versions', action: 'change_position', name: 'Change position')
  end

  def down
    remove_column :versions, :position
    Permission.delete_all(controller: 'Versions', action: 'change_position', name: 'Change position')
  end
end
