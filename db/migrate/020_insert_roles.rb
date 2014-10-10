# Author: Nicolas Meylan
# Date: 14 juil. 2012
# Encoding: UTF-8
# File: 020_insert_roles.rb

class InsertRoles < ActiveRecord::Migration
  def up
    Role.create(name: 'Project Manager', position: 2)
    Role.create(name: 'Team Member', position: 1)
    Role.create(name: 'Engagement Manager', position: 3)
  end

  def down
    Role.delete(1)
    Role.delete(2)
    Role.delete(3)
  end
end


