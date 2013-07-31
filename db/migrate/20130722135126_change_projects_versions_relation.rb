class ChangeProjectsVersionsRelation < ActiveRecord::Migration
  def up
    add_column :versions, :project_id, :integer
    drop_table :projects_versions
  end

  def down
    remove_column :versions, :project_id
  end
end
