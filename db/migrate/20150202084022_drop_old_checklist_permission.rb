class DropOldChecklistPermission < ActiveRecord::Migration
  def up
    Permission.delete_all(controller: 'Issues', action: 'checklist')
  end

  def down

  end
end
