class CreateDocuments < ActiveRecord::Migration
  def up
    create_table :documents do |t|
      t.string :name, limit: 255
      t.text :description, limit: 65555
      t.integer :version_id
      t.integer :category_id
      t.integer :project_id
      t.timestamps null: false
    end
  end

  def down
    drop_table :documents
  end
end
