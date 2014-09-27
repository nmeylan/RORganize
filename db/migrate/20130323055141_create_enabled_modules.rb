class CreateEnabledModules < ActiveRecord::Migration
  def up
    create_table :enabled_modules do |t|
      t.string :name, :limit => 128
      t.string :action, :limit => 255
      t.string :controller, :limit => 255
      t.integer :project_id
    end
  end

  def down
    drop_table :enabled_modules
  end
end
