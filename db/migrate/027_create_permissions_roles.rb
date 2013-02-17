# Author: Nicolas Meylan
# Date: 12 oct. 2012
# Encoding: UTF-8
# File: 027_create_permissions_roles.rb
class CreatePermissionsRoles < ActiveRecord::Migration
  def up
    create_table :permissions_roles, :id => false do |t|
      t.integer :permission_id
      t.integer :role_id
    end
  end

  def down
    drop_table :permissions_roles
  end
end
