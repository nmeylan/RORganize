# Author: Nicolas Meylan
# Date: 12 oct. 2012
# Encoding: UTF-8
# File: 026_create_permissions.rb

class CreatePermissions < ActiveRecord::Migration
  def up
    create_table :permissions do |t|
      t.string :name, :limit => 255
      t.string :action,:limit => 255
      t.string :controller,:limit => 255
    end
  end

  def down
    drop_table :permissions
  end
end
