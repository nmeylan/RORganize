class AddMembersProjectStarred < ActiveRecord::Migration
  def up
    add_column :members, :is_project_starred, :boolean, :default => false
    add_column :members, :project_position, :integer
  end

  def down
    remove_column :members, :is_project_starred
    remove_column :members, :project_position
  end
end
