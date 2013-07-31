class AddJournalTypeAndProjectId < ActiveRecord::Migration
  def up
    add_column :journals, :action_type, :string
    add_column :journals, :project_slug, :integer
  end

  def down
    remove_column :journals, :action_type
    remove_column :journals, :project_slug
  end
end
