# Author: Nicolas Meylan
# Date: 21 juil. 2012
# Encoding: UTF-8
# File: 022_create_journals.rb

class CreateJournals < ActiveRecord::Migration
  def up
    create_table :journals do |t|
      t.string :journalized_type, :limit => 30
      t.text :notes, :limit => 65555
      t.timestamps :created_on
      t.integer :journalized_id
      t.integer :user_id
    end
  end

  def down
    drop_table :journals
  end
end