class CreateMembers < ActiveRecord::Migration
  def up
    create_table :members do |t|
      t.integer :project_slug
      t.integer :user_id
      t.integer :role_id
    end
  end
 
  def down
    drop_table :members
  end
end