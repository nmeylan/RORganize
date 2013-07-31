class AddSlugToProjects < ActiveRecord::Migration
  def up
    add_column :projects, :slug, :string
    add_index :projects, :slug
  end

  def down
    remove_column :projects, :slug
  end
end
