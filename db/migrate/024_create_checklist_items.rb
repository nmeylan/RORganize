# Author: Nicolas Meylan
# Date: 6 août 2012
# Encoding: UTF-8
# File: 024_create_checklist_items.rb

class CreateChecklistItems < ActiveRecord::Migration
  def up
    create_table :checklist_items do |t|
      t.integer :enumeration_id
      t.integer :issue_id
      t.integer :position
      t.string :name, :limit => 50
    end
  end

  def down
    drop_table :checklist_items
  end
end