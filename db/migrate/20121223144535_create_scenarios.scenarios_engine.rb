# This migration comes from scenarios_engine (originally 1)
class CreateScenarios < ActiveRecord::Migration
  def up
    create_table :scenarios do |t|
      t.string :name, :limit => 255
      t.string :description,:limit => 65555
      t.integer :actor_id
      t.integer :version_id
      t.integer :project_slug
      t.timestamps :created_on
      t.timestamps :updated_on
    end
  end

  def down
    drop_table :scenarios
  end
end