class RemoveProjectIdentifierColumn < ActiveRecord::Migration
  def up
    remove_column :projects, :identifier
  end
end
