class CreateChangelogs < ActiveRecord::Migration
  def up
    create_table :changelogs do |t|
      t.integer :version_id
      t.integer :project_id
      t.integer :enumeration_id
      t.text :description, :limit => 65535

    end
  end

  def down
    drop_table :changelogs
  end
end