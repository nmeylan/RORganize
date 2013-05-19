class AddScenariosPermissions < ActiveRecord::Migration
  def up
    Permission.create(:controller => 'Scenarios', :action => 'destroy', :name => 'Delete scenarios')
  end

  def down
    Permission.delete_all(:controller => 'Scenarios', :action => 'destroy', :name => 'Delete scenarios')
  end
end
