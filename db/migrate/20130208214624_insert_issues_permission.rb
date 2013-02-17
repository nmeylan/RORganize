class InsertIssuesPermission < ActiveRecord::Migration
  def up
    Permission.create(:controller => 'Issues', :action => 'edit not owner', :name => "Edit when not issue's owner")
    Permission.create(:controller => 'Issues', :action => 'destroy not owner', :name => "Delete when not issue's owner")
  end

  def down
    Permission.delete_all(:controller => 'Issues', :action => 'edit not owner', :name => "Edit when not issue's owner")
    Permission.delete_all(:controller => 'Issues', :action => 'destroy not owner', :name => "Delete when not issue's owner")
  end
end
