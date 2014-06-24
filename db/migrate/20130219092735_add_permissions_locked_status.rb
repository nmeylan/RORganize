class AddPermissionsLockedStatus < ActiveRecord::Migration
#Permissions with locked status won't be enabled to be deleted anymore.
#Permissions edition will be limited at the name.
#Reason are that, if user deleted a critical permissions, application behaviour can be affected.

  def up
    Permission.update_all(:is_locked => true)
  end

  def down
  end
end
