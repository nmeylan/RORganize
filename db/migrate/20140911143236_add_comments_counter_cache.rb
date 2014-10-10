class AddCommentsCounterCache < ActiveRecord::Migration
  def up
    add_column :issues, :comments_count, :integer, default: 0
    add_column :documents, :comments_count, :integer, default: 0

    Issue.transaction do
      Issue.find_each do |i|
        Issue.update_counters(i.id, comments_count: i.comments.count)
      end
    end
    Document.transaction do
      Document.find_each do |i|
        Document.update_counters(i.id, comments_count: i.comments.count)
      end
    end

  end

  def down
    remove_column :issues, :comments_count
    remove_column :documents, :comments_count

  end
end
