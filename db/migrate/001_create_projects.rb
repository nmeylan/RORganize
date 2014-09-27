class CreateProjects < ActiveRecord::Migration
  def up
    create_table :projects do |t|
      t.string :name, :limit => 255
      t.text :description, :limit => 65535
      t.string :identifier, :limit => 20
      t.timestamps :created_on
      t.timestamps :updated_on
    end
  end

  def down
    drop_table :projects
  end
end