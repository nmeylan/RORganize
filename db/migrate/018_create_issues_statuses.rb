# Author: Nicolas Meylan
# Date: 14 juil. 2012
# Encoding: UTF-8
# File: 018_create_issues_statuses.rb

class CreateIssuesStatuses < ActiveRecord::Migration
  def up
    create_table :issues_statuses do |t|
      t.boolean :is_closed
      t.integer :default_done_ratio
      t.integer :enumeration_id
    end
  end

  def down
    drop_table :issues_statuses
  end
end