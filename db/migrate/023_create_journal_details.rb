# Author: Nicolas Meylan
# Date: 21 juil. 2012
# Encoding: UTF-8
# File: 023_create_journal_details.rb

class CreateJournalDetails < ActiveRecord::Migration
  def up
    create_table :journal_details do |t|
      t.integer :journal_id
      t.string :property, :limit => 30
      t.string :property_key, :limit => 30
      t.string :old_value, :limit => 255
      t.string :value, :limit => 255
    end
  end

  def down
    drop_table :journal_details
  end
end