# Author: Nicolas Meylan
# Date: 14 déc. 2012
# Encoding: UTF-8
# File: 004_create_steps_issues.rb

class CreateStepsIssues < ActiveRecord::Migration
  def up
    create_table :issues_steps, :id => false do |t|
      t.integer :issue_id
      t.integer :step_id
    end
  end

  def down
    drop_table :steps
  end
end
