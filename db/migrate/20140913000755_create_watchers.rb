class CreateWatchers < ActiveRecord::Migration
  def up
    create_table :watchers do |t|
      t.integer :watchable_id
      t.string :watchable_type
      t.integer :user_id
      t.integer :project_id
    end
    add_index :watchers, :watchable_id
  end

  def down
    drop_table :watchers
  end
end
