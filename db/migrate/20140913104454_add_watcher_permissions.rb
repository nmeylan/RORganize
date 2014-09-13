class AddWatcherPermissions < ActiveRecord::Migration
  def up
    Permission.create(controller: 'Projects', action: 'watch', name: 'Watch',  is_locked: true)
  end

  def down
    Permission.delete_all(controller: 'Projects', action: 'watch')
  end
end
