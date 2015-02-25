class CreateProjects < ActiveRecord::Migration
  def up
    create_table :projects do |t|
      t.string :name, limit: 255
      t.text :description, limit: 65535
      t.string :identifier, limit: 20
      t.timestamps null: false
    end
  end

  def down
    drop_table :projects
  end
end