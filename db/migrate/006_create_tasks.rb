class CreateTasks < ActiveRecord::Migration
  def up
    create_table :tasks do |t|
      t.integer :enumeration_id
      t.integer :project_id
      t.integer :issue_id
      t.string :name, :limit => 255
      t.string :description, :limit => 65555
      t.integer :position
      t.timestamps :created_on
      t.timestamps :updated_on
    end
  end
 
  def down
    drop_table :tasks
  end
end