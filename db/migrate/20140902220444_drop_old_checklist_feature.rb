class DropOldChecklistFeature < ActiveRecord::Migration
  def up
    drop_table :checklist_items
    drop_table :tasks
    drop_table :tasks_todo_lists
    drop_table :todo_lists
  end
end
