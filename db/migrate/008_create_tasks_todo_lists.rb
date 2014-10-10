class CreateTasksTodoLists < ActiveRecord::Migration
  def up
    create_table :tasks_todo_lists, id: false do |t|
      t.integer :todo_lists_id
      t.integer :tasks_id

    end
  end

  def down
    drop_table :tasks_todo_lists
  end
end