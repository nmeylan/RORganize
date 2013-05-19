class AddProjectPermission < ActiveRecord::Migration
  def up
    Permission.create(:controller => 'Project', :action => 'destroy', :name => "Delete project")
  end

  def down
    Permission.delete_all(:controller => 'Project', :action => 'destroy', :name => "Delete project")
  end
end
