class CreateWikiPage < ActiveRecord::Migration
  def up
    create_table :wiki_pages do |t|
      t.integer :parent_id
      t.integer :author_id
      t.integer :wiki_id
      t.integer :position
      t.string :title, limit: 255
      t.text :content, limit: 655555
      t.timestamps :created_on
      t.timestamps :updated_on
      t.string :slug
    end

    add_index :wiki_pages, :parent_id
    add_index :wiki_pages, :author_id
    add_index :wiki_pages, :wiki_id
    add_index :wiki_pages, :slug
  end

  def down
    drop_table :wiki_pages
  end
end
