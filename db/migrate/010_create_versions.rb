class CreateVersions < ActiveRecord::Migration
  def up
    create_table :versions do |t|
      t.string :name, :limit => 255
      t.date :target_date
      t.text :description, :limit => 65535
      
    end
  end
 
  def down
    drop_table :versions
  end
end