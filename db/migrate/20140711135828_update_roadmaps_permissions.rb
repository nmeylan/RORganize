class UpdateRoadmapsPermissions < ActiveRecord::Migration
  def up
    Permission.where(controller: 'Roadmap').update_all(controller: 'Roadmaps')
    Permission.where(controller: 'Roadmaps', action: 'index').update_all(action: 'show')
  end

  def down
    Permission.where(controller: 'Roadmaps').update_all(controller: 'Roadmap')
  end
end
