class AddWatchersPermissions < ActiveRecord::Migration
  def up
    Permission.create(controller: 'Issues', action: 'watch', name: 'Watch', is_locked: true)
    Permission.create(controller: 'Wiki_pages', action: 'watch', name: 'Watch', is_locked: true)
    Permission.create(controller: 'Documents', action: 'watch', name: 'Watch', is_locked: true)
  end

  def down
    Permission.delete_all(controller: 'Issues', action: 'watch')
    Permission.delete_all(controller: 'Wiki_pages', action: 'watch')
    Permission.delete_all(controller: 'Documents', action: 'watch')
  end
end
