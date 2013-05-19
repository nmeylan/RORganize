class AddVersionStartDate < ActiveRecord::Migration
  def up
    add_column :versions, :start_date, :date
  end

  def down
    remove_column :versions, :start_date
  end
end
