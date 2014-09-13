class AddWatchersUnwatchColumn < ActiveRecord::Migration
  def up
    add_column :watchers, :is_unwatch, :boolean, default: false
  end

  def down
    remove_column :watchers, :is_unwatch
  end
end
