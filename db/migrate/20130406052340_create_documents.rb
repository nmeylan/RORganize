class CreateDocuments < ActiveRecord::Migration
  def up
    create_table :documents do |t|
      t.string :name, :limit => 255
      t.string :description,:limit => 65555
      t.integer :version_id
      t.integer :category_id
      t.integer :project_id
      t.timestamps :created_on
      t.timestamps :updated_on
    end
  end

  def down
    drop_table :documents
  end
end
