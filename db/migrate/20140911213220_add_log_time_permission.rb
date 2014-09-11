class AddLogTimePermission < ActiveRecord::Migration
  def up
    Permission.create(controller: 'Time_entries', action: 'new', name: 'Log time', is_locked: true)
    Permission.create(controller: 'Time_entries', action: 'edit', name: 'Edit logged time', is_locked: true)
    Permission.create(controller: 'Time_entries', action: 'destroy', name: 'Delete logged time', is_locked: true)
  end

  def down
    Permission.delete_all(controller: 'Time_entries', action: 'new', name: 'Log time')
    Permission.delete_all(controller: 'Time_entries', action: 'edit', name: 'Edit logged time')
    Permission.delete_all(controller: 'Time_entries', action: 'destroy', name: 'Delete logged time')
  end
end
