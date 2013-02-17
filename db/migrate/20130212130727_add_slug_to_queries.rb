class AddSlugToQueries < ActiveRecord::Migration
  def up
    add_column :queries, :slug, :string
    add_index :queries, :slug
  end

  def down
    remove_column :queries, :slug
  end
end
