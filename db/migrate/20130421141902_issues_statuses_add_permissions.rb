class IssuesStatusesAddPermissions < ActiveRecord::Migration
  def up
    Permission.create(:controller => 'Issues_statuses', :action => 'index', :name => 'View issues statuses', :is_locked => true)
    Permission.create(:controller => 'Issues_statuses', :action => 'new', :name => 'Create issues statuses', :is_locked => true)
    Permission.create(:controller => 'Issues_statuses', :action => 'edit', :name => 'Edit issues statuses', :is_locked => true)
    Permission.create(:controller => 'Issues_statuses', :action => 'destroy', :name => 'Delete issues statuses', :is_locked => true)
    Permission.create(:controller => 'Issues_statuses', :action => 'show', :name => 'View issues status', :is_locked => true)
  end

  def down
    Permission.delete_all(:controller => 'Issues_statuses', :action => 'index', :name => 'View issues statuses')
    Permission.delete_all(:controller => 'Issues_statuses', :action => 'new', :name => 'Create issues statuses')
    Permission.delete_all(:controller => 'Issues_statuses', :action => 'edit', :name => 'Edit issues statuses')
    Permission.delete_all(:controller => 'Issues_statuses', :action => 'destroy', :name => 'Delete issues statuses')
    Permission.delete_all(:controller => 'Issues_statuses', :action => 'show', :name => 'View issues status')
  end
end
