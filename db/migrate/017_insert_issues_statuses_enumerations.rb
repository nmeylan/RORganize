# Author: Nicolas Meylan
# Date: 14 juil. 2012
# Encoding: UTF-8
# File: 017_insert_issues_statuses.rb

class InsertIssuesStatusesEnumerations < ActiveRecord::Migration
  def up
    Enumeration.create(:opt => 'ISTS', :name => 'New', :position => 1)
    Enumeration.create(:opt => 'ISTS', :name => 'In progress', :position => 2)
    Enumeration.create(:opt => 'ISTS', :name => 'Closed', :position => 7)
    Enumeration.create(:opt => 'ISTS', :name => 'Fixed to test', :position => 3)
    Enumeration.create(:opt => 'ISTS', :name => 'Tested to be delivered', :position => 6)
    Enumeration.create(:opt => 'ISTS', :name => 'Not satisfying', :position => 5)
    Enumeration.create(:opt => 'ISTS', :name => 'Redo', :position => 4)
  end

  def down
    Enumeration.delete(1)
    Enumeration.delete(2)
    Enumeration.delete(3)
    Enumeration.delete(4)
    Enumeration.delete(5)
    Enumeration.delete(6)
    Enumeration.delete(7)
  end
end

