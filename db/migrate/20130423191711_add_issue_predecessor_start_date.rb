class AddIssuePredecessorStartDate < ActiveRecord::Migration
  def up
    add_column :issues, :start_date, :date
    add_column :issues, :predecessor_id, :integer
  end

  def down
    remove_column :issues, :start_date
    remove_column :issues, :predecessor_id
  end
end
