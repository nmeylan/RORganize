# Author: Nicolas Meylan
# Date: 13 juil. 2012
# Encoding: UTF-8
# File: 013_create_tracker.rb

class CreateTrackers < ActiveRecord::Migration
  def up
    create_table :trackers do |t|
      t.boolean :is_in_chlog
      t.boolean :is_in_roadmap
      t.string :name, limit: 255
      t.integer :position
    end
  end

  def down
    drop_table :trackers
  end
end