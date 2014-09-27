class CreateEnumerations < ActiveRecord::Migration
  def up
    create_table :enumerations do |t|
      t.string :opt, :limit => 4
      t.string :name, :limit => 255
      t.integer :position
    end
  end

  def down
    drop_table :enumerations
  end
end