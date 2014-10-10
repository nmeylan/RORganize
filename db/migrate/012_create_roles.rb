class CreateRoles < ActiveRecord::Migration
  def up
    create_table :roles do |t|
      t.string :name, limit: 255
      t.integer :position
    end
  end

  def down
    drop_table :roles
  end
end