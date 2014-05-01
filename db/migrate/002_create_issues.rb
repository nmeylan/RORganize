class CreateIssues < ActiveRecord::Migration
  def up
    create_table :issues do |t|
      t.string :subject, :limit => 255
      t.text :description,:limit => 65535
      t.timestamps :created_on
      t.timestamps :updated_on
      t.date :due_date
      t.integer :done
      t.integer :author_id
      t.integer :assigned_to_id
      t.integer :project_id
      t.integer :tracker_id
      t.integer :status_id
      t.integer :version_id
      t.integer :category_id
      t.decimal :estimated_time, :precision => 10, :scale => 1
    end
  end

  def down
    drop_table :issues
  end
end