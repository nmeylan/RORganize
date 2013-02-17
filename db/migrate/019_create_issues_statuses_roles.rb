# Author: Nicolas Meylan
# Date: 14 juil. 2012
# Encoding: UTF-8
# File: 019_create_issues_statuses_roles.rb

class CreateIssuesStatusesRoles < ActiveRecord::Migration
  def up
    create_table :issues_statuses_roles, :id => false do |t|
      t.integer :role_id
      t.integer :issues_status_id
    end
  end

  def down
    drop_table :issues_statuses_roles
  end
end
