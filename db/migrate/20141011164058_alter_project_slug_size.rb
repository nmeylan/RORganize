class AlterProjectSlugSize < ActiveRecord::Migration
  def change
    change_column :projects, :slug, :string, length: 125
  end
end
