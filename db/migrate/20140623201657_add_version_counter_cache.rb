class AddVersionCounterCache < ActiveRecord::Migration
  def up
    add_column :versions, :issues_count, :integer, :default => 0

    Version.reset_column_information
    Version.all.each do |i|
      Version.update_counters i.id, :issues_count => i.issues.length
    end

  end

  def down
    remove_column :versions, :issues_count

  end
end
