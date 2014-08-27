class InsertRoadmapPermissions < ActiveRecord::Migration
  def up
    Permission.create(:controller => 'Roadmaps', :action => 'gantt', :name => 'View gantt', :is_locked => true)
    Permission.create(:controller => 'Roadmaps', :action => 'manage_gantt', :name => 'Edit gantt', :is_locked => true)
  end

  def down
    Permission.delete_all(:controller => 'Roadmaps', :action => 'gantt', :name => 'view Gantt')
    Permission.delete_all(:controller => 'Roadmaps', :action => 'manage_gantt', :name => 'Edit gantt')
  end
end
