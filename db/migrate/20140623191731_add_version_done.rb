class AddVersionDone < ActiveRecord::Migration
  def up
    add_column :versions, :is_done, :boolean
  end

  def down
    remove_column :versions, :is_done
  end
end
