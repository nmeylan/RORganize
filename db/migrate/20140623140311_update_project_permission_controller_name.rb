class UpdateProjectPermissionControllerName < ActiveRecord::Migration
  def change
    Permission.where(controller: 'Project').update_all(controller: 'Projects')
  end
end
