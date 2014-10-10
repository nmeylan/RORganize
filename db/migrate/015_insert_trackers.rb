# Author: Nicolas Meylan
# Date: 13 juil. 2012
# Encoding: UTF-8
# File: 015_insert_trackers.rb

class InsertTrackers < ActiveRecord::Migration
  def up
    Tracker.create(name: 'Task', is_in_chlog: true, is_in_roadmap: true, position: 1)
    Tracker.create(name: 'Bug', is_in_chlog: true, is_in_roadmap: true, position: 2)
  end

  def down
    Tracker.delete(1)
    Tracker.delete(2)
  end
end
