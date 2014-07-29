class CreateComments < ActiveRecord::Migration
  def up
    create_table :comments do |t|
      t.text :content
      t.datetime :created_at
      t.datetime :updated_at
      t.integer :commentable_id
      t.string :commentable_type
      t.integer :user_id
      t.integer :parent_id
      t.integer :project_id
    end
    add_index :comments, :commentable_id
  end

  def down
    drop_table :comments
  end
end
