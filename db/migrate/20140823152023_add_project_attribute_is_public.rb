class AddProjectAttributeIsPublic < ActiveRecord::Migration
  def up
    add_column :projects, :is_public, :boolean, default: false
  end

  def down
    remove_column :projects, :is_public
  end
end
