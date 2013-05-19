class AddProjectAttributes < ActiveRecord::Migration
  def up
    add_column :projects, :created_by, :integer
  end

  def down
    remove_column :projects, :created_by
  end
end
