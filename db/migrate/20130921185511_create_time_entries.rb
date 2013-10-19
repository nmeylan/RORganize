class CreateTimeEntries < ActiveRecord::Migration
  def up
    create_table :time_entries do |t|
      t.integer :user_id
      t.integer :issue_id
      t.integer :project_id
      t.date :spent_on
      t.float :spent_time
      t.text :comment
    end
  end

  def down
    drop_table :time_entries
  end
end
