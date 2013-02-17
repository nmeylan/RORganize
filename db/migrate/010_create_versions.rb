class CreateVersions < ActiveRecord::Migration
  def up
    create_table :versions do |t|
      t.string :name, :limit => 255
      t.date :target_date
      t.string :description, :limit => 65555
      
    end
  end
 
  def down
    drop_table :versions
  end
end