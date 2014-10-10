class AddIssuesCounterCache < ActiveRecord::Migration
  def up
    add_column :issues, :checklist_items_count, :integer, default: 0
    add_column :issues, :attachments_count, :integer, default: 0

    Issue.reset_column_information
    Issue.all.each do |i|
      Issue.update_counters i.id, attachments_count: i.attachments.length
    end
    Issue.reset_column_information
    Issue.all.each do |i|
      Issue.update_counters i.id, checklist_items_count: i.checklist_items.length
    end
  end

  def down
    remove_column :issues, :checklist_items_count
    remove_column :issues, :attachments_count
  end
end
