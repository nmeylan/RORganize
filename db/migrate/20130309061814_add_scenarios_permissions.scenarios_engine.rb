# This migration comes from scenarios_engine (originally 20130309055606)
class AddScenariosPermissions < ActiveRecord::Migration
  def up
    Permission.create(controller: 'Scenarios', action: 'delete', name: 'Delete scenarios', is_locked: true)
  end

  def down
    Permission.delete_all(controller: 'Scenarios', action: 'delete', name: 'Delete scenarios')
  end
end
