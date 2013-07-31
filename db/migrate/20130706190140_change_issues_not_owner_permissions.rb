class ChangeIssuesNotOwnerPermissions < ActiveRecord::Migration
  def up
    p1 = Permission.find_by_controller_and_action('Issues', 'edit not owner')
    p2 = Permission.find_by_controller_and_action('Issues', 'destroy not owner')
    p1.update_column(:action, "edit_not_owner") if p1
    p2.update_column(:action, "destroy_not_owner") if p2
  end

  def down
  end
end
