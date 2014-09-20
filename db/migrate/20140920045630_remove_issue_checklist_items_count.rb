class RemoveIssueChecklistItemsCount < ActiveRecord::Migration
  def up
    remove_column :issues, :checklist_items_count
  end

  def down
    add_column :issues, :checklist_items_count, :integer
  end
end



