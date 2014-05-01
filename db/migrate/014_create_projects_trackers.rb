# Author: Nicolas Meylan
# Date: 13 juil. 2012
# Encoding: UTF-8
# File: 014_create_projects_trackers.rb

class CreateProjectsTrackers < ActiveRecord::Migration
  def up
    create_table :projects_trackers, :id => false do |t|
      t.integer :tracker_id
      t.integer :project_id
    end
  end

  def down
    drop_table :projects_trackers
  end
end