class CreateQueries < ActiveRecord::Migration
  def up
    create_table :queries do |t|
      t.integer :author_id
      t.integer :project_slug
      t.boolean :is_for_all
      t.boolean :is_public
      t.string :name, :limit => 50
      t.string :description, :limit => 65555
      t.string :stringify_params, :limit => 65555
      t.string :stringify_query, :limit => 65555
      t.string :object_type
    end
  end

  def down
    drop_table :queries
  end
end
