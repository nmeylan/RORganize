class AddIssuesPermissions < ActiveRecord::Migration
  def up
    Permission.create(:controller => 'Issues', :action => 'add_predecessor', :name => "Add predecessor")
    Permission.create(:controller => 'Issues', :action => 'del_predecessor', :name => "Delete predecessor")
  end

  def down
    Permission.delete_all(:controller => 'Issues', :action => 'add_predecessor', :name => "Add predecessor")
    Permission.delete_all(:controller => 'Issues', :action => 'del_predecessor', :name => "Delete predecessor")
  end
end
