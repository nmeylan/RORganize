class CreateTodoLists < ActiveRecord::Migration
  def up
    create_table :todo_lists do |t|
      t.integer :user_id
      t.integer :project_slug
      t.string :name, :limit => 255
      t.string :description, :limit => 65555
      t.timestamps :created_on
      t.timestamps :updated_on
    end
  end
 
  def down
    drop_table :todo_lists
  end
end