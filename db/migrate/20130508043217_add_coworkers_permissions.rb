class AddCoworkersPermissions < ActiveRecord::Migration
  def up
    Permission.create(controller: 'Coworkers', action: 'display_activities', name: 'Display activities', is_locked: true)
    Permission.create(controller: 'Coworkers', action: 'index', name: 'View coworkers', is_locked: true)
  end

  def down
    Permission.delete_all(controller: 'Coworkers', action: 'display_activities', name: 'Display activities')
    Permission.delete_all(controller: 'Coworkers', action: 'index', name: 'View coworkers')
  end
end
