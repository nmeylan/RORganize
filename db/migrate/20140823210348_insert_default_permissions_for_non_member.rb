class InsertDefaultPermissionsForNonMember < ActiveRecord::Migration
  def up
    anonymous_role = Role.find_by_name('Non member')
    anonymous_role.permissions = Permission.where("
    (action = 'index' AND controller = 'Documents') OR
    (action = 'show' AND controller = 'Documents') OR
    (action = 'new' AND controller = 'Issues') OR
    (action = 'edit' AND controller = 'Issues') OR
    (action = 'destroy' AND controller = 'Issues') OR
    (action = 'index' AND controller = 'Issues') OR
    (action = 'show' AND controller = 'Issues') OR
    (action = 'apply_custom_query' AND controller = 'Issues') OR
    (action = 'comment' AND controller = 'Issues') OR
    (action = 'overview' AND controller = 'Projects') OR
    (action = 'activity' AND controller = 'Projects') OR
    (action = 'show' AND controller = 'Projects') OR
    (action = 'index' AND controller = 'Projects') OR
    (action = 'show' AND controller = 'Roadmaps') OR
    (action = 'index' AND controller = 'Wiki') OR
    (action = 'pages' AND controller = 'Wiki')")
    anonymous_role.save
  end

  def down
    anonymous_role = Role.find_by_name('Non member')
    anonymous_role.permissions.clear
    anonymous_role.save
  end
end
