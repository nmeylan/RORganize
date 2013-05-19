class AddModulesPermissions < ActiveRecord::Migration
  def up
    Permission.create(:controller => 'Settings', :action => 'modules', :name => "manage modules", :is_locked => true)
  end

  def down
    Permission.delete_all(:controller => 'Settings', :action => 'modules', :name => "manage modules")
  end
end
