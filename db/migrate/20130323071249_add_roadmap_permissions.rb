class AddRoadmapPermissions < ActiveRecord::Migration
  def up
    Permission.create(:controller => 'Roadmap', :action => 'index', :name => 'view roadmap', :is_locked => true)
  end

  def down
    Permission.delete_all(:controller => 'Roadmap', :action => 'index', :name => 'view roadmap')
  end
end
