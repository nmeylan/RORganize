class AddProjectsCounterCache < ActiveRecord::Migration
  def up
    add_column :projects, :members_count, :integer, :default => 0
    add_column :projects, :issues_count, :integer, :default => 0
    add_column :projects, :attachments_count, :integer, :default => 0

    Project.reset_column_information
    Project.all.each do |i|
      Project.update_counters i.id, :attachments_count => i.attachments.length
    end
    Project.reset_column_information
    Project.all.each do |i|
      Project.update_counters i.id, :issues_count => i.issues.length
    end
    Project.reset_column_information
    Project.all.each do |i|
      Project.update_counters i.id, :members_count => i.members.length
    end
  end

  def down
     remove_column :issues, :issues_count
     remove_column :issues, :members_count
    remove_column :issues, :attachments_count 
  end
end
