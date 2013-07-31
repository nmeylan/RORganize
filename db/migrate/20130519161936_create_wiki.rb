class CreateWiki < ActiveRecord::Migration
  def up
    create_table :wikis do |t|
      t.integer :home_page_id
      t.integer :project_slug
    end

    add_index :wikis, :project_slug
    add_index :wikis, :home_page_id
  end

  def down
    drop_table :wikis
  end
end
