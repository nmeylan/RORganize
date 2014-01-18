class UpdateMembersPermissions < ActiveRecord::Migration
  def up
    p1 = Permission.find_by_controller_and_name('Members','Add members')
    p1.update_column(:action, 'new')

  end

  def down
  end
end
