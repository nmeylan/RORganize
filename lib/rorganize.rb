# Author: Nicolas Meylan
# Date: 9 févr. 2013
# Encoding: UTF-8
# File: rorganize.rb

require "rorganize/menu_manager"
require "rorganize/module_manager"
require "rorganize/permission_manager"

I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
Rorganize::MenuManager.map :project_menu do |menu|
  #menu.add(menu_name, menu_url, options)
  #If you have one menu item per controller
  #Id must be declare as following: menu_controller
  #If you have more than one item per controller
  #Id must be declare as following: menu_controller_action
  menu.add(:overview, I18n.t(:label_overview), {:controller => 'projects', :action => 'overview'}, {:id => "menu_projects_overview"})
  menu.add(:activity, I18n.t(:label_activity), {:controller => 'projects', :action => 'activity'}, {:id => "menu_projects_activity"})
  menu.add(:roadmap, I18n.t(:label_roadmap), {:controller => 'roadmap', :action => 'index'}, {:id => "menu_roadmap"})
  menu.add(:requests, I18n.t(:label_request_plural), {:controller => 'issues', :action => 'index'}, {:id => "menu_issues"})
  menu.add(:wiki, I18n.t(:label_wiki),  {:controller => 'wiki', :action => 'index'}, {:id => "menu_wiki"})
  #  menu.add(t(:label_test_plural), "#")
  menu.add(:documents, I18n.t(:label_documents), {:controller => 'documents', :action => 'index'}, {:id => "menu_documents"})
  menu.add(:settings, I18n.t(:label_setting_plural), {:controller => 'settings', :action => 'index'}, {:id => "menu_settings"})
end

Rorganize::MenuManager.map :admin_menu do |menu|
  menu.add(:permissions, I18n.t(:link_permissions), {:controller => 'permissions', :action => 'index'}, {:id => "menu_permissions"})
  menu.add(:roles, I18n.t(:link_roles), {:controller => 'roles', :action => 'index'}, {:id => "menu_roles"})
  menu.add(:users, I18n.t(:link_users), {:controller => 'users', :action => 'index'}, {:id => "menu_users"})
  menu.add(:queries, I18n.t(:link_queries), {:controller => 'administration', :action => 'public_queries'}, {:id => "menu_administration_public_queries"})
  menu.add(:trackers, I18n.t(:link_trackers), {:controller => 'trackers', :action => 'index'}, {:id => "menu_trackers"})
  menu.add(:issues_statuses, I18n.t(:link_issues_statuses), {:controller => 'issues_statuses', :action => 'index'}, {:id => "menu_issues_statuses"})
end

Rorganize::MenuManager.map :top_menu do |menu|
  menu.add(:projects, I18n.t(:label_project_plural), {:controller => 'projects', :action => 'index'}, {:id => "menu_projects"})
  menu.add(:administration, I18n.t(:link_administration), {:controller => 'administration', :action => 'index'}, {:id => "menu_administration"})
  menu.add(:coworkers, I18n.t(:link_coworkers), {:controller => 'coworkers', :action => 'index'}, {:id => "menu_coworkers"})
end


Rorganize::PermissionManager.initialize