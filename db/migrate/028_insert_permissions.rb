# Author: Nicolas Meylan
# Date: 13 oct. 2012
# Encoding: UTF-8
# File: 028_insert_permissions.rb

class InsertPermissions < ActiveRecord::Migration
  def up
    #Permissions for issues
    Permission.create(controller: 'Issues', action: 'new', name: 'Create issues')
    Permission.create(controller: 'Issues', action: 'index', name: 'View issues')
    Permission.create(controller: 'Issues', action: 'show', name: 'View issue')
    Permission.create(controller: 'Issues', action: 'edit', name: 'Edit issues')
    Permission.create(controller: 'Issues', action: 'checklist', name: 'Use checklist')
    Permission.create(controller: 'Issues', action: 'change_version', name: 'Change versions')
    Permission.create(controller: 'Issues', action: 'change_category', name: 'Change category')
    Permission.create(controller: 'Issues', action: 'change_progress', name: 'Change progress')
    Permission.create(controller: 'Issues', action: 'change_assigned', name: 'Change assigned')
    Permission.create(controller: 'Issues', action: 'change_status', name: 'Change status')
    Permission.create(controller: 'Issues', action: 'destroy', name: 'Delete issues')
    Permission.create(controller: 'Issues', action: 'delete_attachment', name: 'Add or delete attachments')
    #Permissions for project's setting
    Permission.create(controller: 'Settings', action: 'index', name: 'Access to settings')
    Permission.create(controller: 'Settings', action: 'update_project_informations', name: 'Edit project informations')
    #Permissions for project's member
    Permission.create(controller: 'Members', action: 'index', name: 'View members')
    Permission.create(controller: 'Members', action: 'destroy', name: 'Delete members')
    Permission.create(controller: 'Members', action: 'change_role', name: 'Change role')
    Permission.create(controller: 'Members', action: 'add_member', name: 'Add members')
    #Permissions for project's categories
    Permission.create(controller: 'Categories', action: 'index', name: 'View categories')
    Permission.create(controller: 'Categories', action: 'new', name: 'Create categories')
    Permission.create(controller: 'Categories', action: 'edit', name: 'Edit categories')
    Permission.create(controller: 'Categories', action: 'destroy', name: 'Delete categories')
    Permission.create(controller: 'Categories', action: 'show', name: 'View category')
    #Permissions for project's versions
    Permission.create(controller: 'Versions', action: 'index', name: 'View versions')
    Permission.create(controller: 'Versions', action: 'new', name: 'Create versions')
    Permission.create(controller: 'Versions', action: 'edit', name: 'Edit versions')
    Permission.create(controller: 'Versions', action: 'destroy', name: 'Delete versions')
    Permission.create(controller: 'Versions', action: 'show', name: 'View version')
    #Permissions for administration
    Permission.create(controller: 'Administration', action: 'index', name: 'Access to administration')
    #Permissions for users
    Permission.create(controller: 'Users', action: 'index', name: 'View users')
    Permission.create(controller: 'Users', action: 'new', name: 'Create users')
    Permission.create(controller: 'Users', action: 'edit', name: 'Edit users')
    Permission.create(controller: 'Users', action: 'destroy', name: 'Delete users')
    Permission.create(controller: 'Users', action: 'show', name: 'View user')
    #Permissions for permissions
    Permission.create(controller: 'Permissions', action: 'index', name: 'View permissions')
    Permission.create(controller: 'Permissions', action: 'new', name: 'Create permissions')
    Permission.create(controller: 'Permissions', action: 'edit', name: 'Edit permissions')
    Permission.create(controller: 'Permissions', action: 'destroy', name: 'Delete permissions')
    Permission.create(controller: 'Permissions', action: 'show', name: 'View permission')
    Permission.create(controller: 'Permissions', action: 'list', name: 'Change roles permissions')
    #Permissions for project
    Permission.create(controller: 'Project', action: 'overview', name: 'View project overview')
    Permission.create(controller: 'Project', action: 'activity', name: 'View project activity')
    Permission.create(controller: 'Project', action: 'rodmap', name: 'View project roadmap')
    Permission.create(controller: 'Project', action: 'new', name: 'Create projects')
    Permission.create(controller: 'Project', action: 'show', name: 'View project')
    #Permissions for project
    Permission.create(controller: 'Projects', action: 'index', name: 'View projects')
    #Permissions for roles
    Permission.create(controller: 'Roles', action: 'index', name: 'View roles')
    Permission.create(controller: 'Roles', action: 'new', name: 'Create roles')
    Permission.create(controller: 'Roles', action: 'edit', name: 'Edit roles')
    Permission.create(controller: 'Roles', action: 'destroy', name: 'Delete roles')
    Permission.create(controller: 'Roles', action: 'show', name: 'View role')
    #Permissions for trackers
    Permission.create(controller: 'Trackers', action: 'index', name: 'View trackers')
    Permission.create(controller: 'Trackers', action: 'new', name: 'Create trackers')
    Permission.create(controller: 'Trackers', action: 'edit', name: 'Edit trackers')
    Permission.create(controller: 'Trackers', action: 'destroy', name: 'Delete trackers')
    Permission.create(controller: 'Trackers', action: 'show', name: 'View role')
  end

  def down
    Permission.delete_all(controller: 'Issues', action: 'new', name: 'Create issues')
    Permission.delete_all(controller: 'Issues', action: 'index', name: 'View issues')
    Permission.delete_all(controller: 'Issues', action: 'show', name: 'View issue')
    Permission.delete_all(controller: 'Issues', action: 'edit', name: 'Edit issues')
    Permission.delete_all(controller: 'Issues', action: 'checklist', name: 'Use checklist')
    Permission.delete_all(controller: 'Issues', action: 'change_version', name: 'Change versions')
    Permission.delete_all(controller: 'Issues', action: 'change_category', name: 'Change category')
    Permission.delete_all(controller: 'Issues', action: 'destroy', name: 'Delete issues')
    Permission.delete_all(controller: 'Issues', action: 'change_progress', name: 'Change progress')
    Permission.delete_all(controller: 'Issues', action: 'change_assigned', name: 'Change assigned')
    Permission.delete_all(controller: 'Issues', action: 'change_status', name: 'Change status')
    Permission.delete_all(controller: 'Issues', action: 'delete_attachment', name: 'Add or delete attachments')
    #Permissions for project's setting
    Permission.delete_all(controller: 'Settings', action: 'index', name: 'Access to settings')
    Permission.delete_all(controller: 'Settings', action: 'update_project_informations', name: 'Edit project informations')
    #Permissions for project
    Permission.delete_all(controller: 'Projects', action: 'index', name: 'View projects')
    #Permissions for project's member
    Permission.delete_all(controller: 'Members', action: 'index', name: 'View members')
    Permission.delete_all(controller: 'Members', action: 'destroy', name: 'Delete members')
    Permission.delete_all(controller: 'Members', action: 'change_role', name: 'Change role')
    Permission.delete_all(controller: 'Members', action: 'add_member', name: 'Add members')
    #Permissions for project's categories
    Permission.delete_all(controller: 'Categories', action: 'index', name: 'View categories')
    Permission.delete_all(controller: 'Categories', action: 'new', name: 'Create categories')
    Permission.delete_all(controller: 'Categories', action: 'edit', name: 'Edit categories')
    Permission.delete_all(controller: 'Categories', action: 'destroy', name: 'Delete categories')
    Permission.delete_all(controller: 'Categories', action: 'show', name: 'View category')
    #Permissions for project's versions
    Permission.delete_all(controller: 'Versions', action: 'index', name: 'View versions')
    Permission.delete_all(controller: 'Versions', action: 'new', name: 'Create versions')
    Permission.delete_all(controller: 'Versions', action: 'edit', name: 'Edit versions')
    Permission.delete_all(controller: 'Versions', action: 'destroy', name: 'Delete versions')
    Permission.delete_all(controller: 'Versions', action: 'show', name: 'View version')
    #Permissions for administration
    Permission.delete_all(controller: 'Administration', action: 'index', name: 'Access to administration')
    #Permissions for users
    Permission.delete_all(controller: 'Users', action: 'index', name: 'View users')
    Permission.delete_all(controller: 'Users', action: 'new', name: 'Create users')
    Permission.delete_all(controller: 'Users', action: 'edit', name: 'Edit users')
    Permission.delete_all(controller: 'Users', action: 'destroy', name: 'Delete users')
    Permission.delete_all(controller: 'Users', action: 'show', name: 'View user')
    #Permissions for permissions
    Permission.delete_all(controller: 'Permissions', action: 'index', name: 'View permissions')
    Permission.delete_all(controller: 'Permissions', action: 'new', name: 'Create permissions')
    Permission.delete_all(controller: 'Permissions', action: 'edit', name: 'Edit permissions')
    Permission.delete_all(controller: 'Permissions', action: 'destroy', name: 'Delete permissions')
    Permission.delete_all(controller: 'Permissions', action: 'show', name: 'View permission')
    Permission.delete_all(controller: 'Permissions', action: 'list', name: 'Change roles permissions')
    #Permissions for project
    Permission.delete_all(controller: 'Project', action: 'overview', name: 'View project overview')
    Permission.delete_all(controller: 'Project', action: 'activity', name: 'View project activity')
    Permission.delete_all(controller: 'Project', action: 'new', name: 'Create projects')
    Permission.delete_all(controller: 'Project', action: 'show', name: 'View project')
    #Permissions for roles
    Permission.delete_all(controller: 'Roles', action: 'index', name: 'View roles')
    Permission.delete_all(controller: 'Roles', action: 'new', name: 'Create roles')
    Permission.delete_all(controller: 'Roles', action: 'edit', name: 'Edit roles')
    Permission.delete_all(controller: 'Roles', action: 'destroy', name: 'Delete roles')
    Permission.delete_all(controller: 'Roles', action: 'show', name: 'View role')
    #Permissions for trackers
    Permission.delete_all(controller: 'Trackers', action: 'index', name: 'View trackers')
    Permission.delete_all(controller: 'Trackers', action: 'new', name: 'Create trackers')
    Permission.delete_all(controller: 'Trackers', action: 'edit', name: 'Edit trackers')
    Permission.delete_all(controller: 'Trackers', action: 'destroy', name: 'Delete trackers')
    Permission.delete_all(controller: 'Trackers', action: 'show', name: 'View role')
  end
end