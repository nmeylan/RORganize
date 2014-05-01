class CreateTodoLists < ActiveRecord::Migration
  def up
    create_table :todo_lists do |t|
      t.integer :user_id
      t.integer :project_id
      t.string :name, :limit => 255
      t.text :description, :limit => 65535
      t.timestamps :created_on
      t.timestamps :updated_on
    end
  end
 
  def down
    drop_table :todo_lists
  end
end