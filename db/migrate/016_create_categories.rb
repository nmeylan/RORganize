# Author: Nicolas Meylan
# Date: 14 juil. 2012
# Encoding: UTF-8
# File: 016_create_categories.rb

class CreateCategories < ActiveRecord::Migration
  def up
    create_table :categories do |t|
      t.integer :project_id
      t.string :name, limit: 255
    end
  end

  def down
    drop_table :categories
  end
end