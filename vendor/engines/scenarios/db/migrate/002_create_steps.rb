class CreateSteps < ActiveRecord::Migration
  def up
    create_table :steps do |t|
      t.string :name, :limit => 255
      t.integer :scenario_id
    end
  end

  def down
    drop_table :steps
  end
end