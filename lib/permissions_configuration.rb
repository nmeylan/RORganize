# Author: Nicolas Meylan
# Date: 05.09.14
# Encoding: UTF-8
# File: permissions_configuration.rb

#Here you have to define your controllers groups.
#There are 3 groups :
# project
# administration
# misc

#These groups are used to display the controllers list in the administration panel.
#If no group is provided for a controller, it will be assigned to the misc group by default.
groups = {
    project: [
        'categories',
        'comments',
        'documents',
        'issues',
        'members',
        'projects',
        'queries',
        'roadmaps',
        'settings',
        'time_entries',
        'versions',
        'wiki',
        'wiki_pages'
    ],
    administration: [
        'administration',
        'issues_statuses',
        'permissions',
        'roles',
        'trackers',
        'users'
    ],
    misc: []
}
Rorganize::Managers::PermissionManager.set_controllers_groups(groups)


module Rorganize
  #Define permissions categories here (only use to group permissions on the list render)
  PERMISSIONS_LIST_ROW_CATEGORIES = {read: ['view', 'access', 'consult', 'use'], create: ['create', 'add', 'new'], update: ['edit', 'update', 'change', 'organize', 'manage', 'archive'], delete: ['delete', 'destroy', 'remove']}
end