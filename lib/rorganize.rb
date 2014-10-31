# Author: Nicolas Meylan
# Date: 9 févr. 2013
# Encoding: UTF-8
# File: rorganize.rb

require 'rorganize/managers/menu_manager'
require 'rorganize/managers/permission_manager'
require 'rorganize/managers/module_manager'
require 'rorganize/managers/plugin_manager'

module Rorganize
  TIME_FORMAT = '%a. %-d %b. %I:%M %p.'
  TIME_FORMAT_Y = '%-d %b. %Y %I:%M %p.'
  DATE_FORMAT_Y = '%-d %b. %Y'
  #ICONS
  ACTION_ICON = {version_id: 'milestone', due_date: 'today', assigned_to_id: 'person', status_id: 'dashboard', category_id: 'tag', done: 'pulse', tracker_id: 'issue-opened', admin: 'crown', email: 'mail'}
  #ROLES constants
  NON_MEMBER_ROLE = 'Non member'

end

unless $0.end_with?('rake')

  I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
  Rorganize::Managers::MenuManager.map :project_menu do |menu|
    #menu.add(module_name, menu_url, options)
    #module_name : is the name of the associated module. Module need to be activate(at settings->module) to perform actions from controller.
    #menu_url must be under hash format and not route_path(..)
    #General case : If you have one menu item per controller
    #   then Client id must be declare as following: menu_controller. All action from this controller will be activate when module module_name is activate.
    #If you want a specific menu for differents actions from a same controller
    #   then Client id must be declare as following: menu_controller_action. However, only these action will be activate(by default) when the module module_name is activate.
    #Here same controller but a menu for both actions :
    menu.add(:overview, I18n.t(:label_overview), {controller: 'projects', action: 'overview'}, {id: 'menu-projects-overview', glyph: 'repo'})
    menu.add(:activity, I18n.t(:label_activity), {controller: 'projects', action: 'activity'}, {id: 'menu-projects-activity', glyph: 'rss'})
    #Same here
    menu.add(:roadmaps, I18n.t(:label_roadmap), {controller: 'roadmaps', action: 'show'}, {id: 'menu-roadmaps', glyph: 'milestone'})
    #One menu for all action from issues_controller
    menu.add(:requests, I18n.t(:label_request_plural), {controller: 'issues', action: 'index'}, {id: 'menu-issues', glyph: 'issue-opened'})
    menu.add(:documents, I18n.t(:label_documents), {controller: 'documents', action: 'index'}, {id: 'menu-documents', glyph: 'file-text'})
    menu.add(:wiki, I18n.t(:label_wiki), {controller: 'wiki', action: 'index'}, {id: 'menu-wiki', glyph: 'book'})
    menu.add(:settings, I18n.t(:label_setting_plural), {controller: 'settings', action: 'index'}, {id: 'menu-settings', glyph: 'tools'})
  end

  Rorganize::Managers::MenuManager.map :admin_menu do |menu|
    menu.add(:permissions, I18n.t(:link_permissions), {controller: 'permissions', action: 'index'}, {id: 'menu-permissions', glyph: 'key'})
    menu.add(:roles, I18n.t(:link_roles), {controller: 'roles', action: 'index'}, {id: 'menu-roles', glyph: 'person'})
    menu.add(:users, I18n.t(:link_users), {controller: 'users', action: 'index'}, {id: 'menu-users', glyph: 'organization'})
    menu.add(:queries, I18n.t(:link_queries), {controller: 'queries', action: 'index'}, {id: 'menu-queries-index', glyph: 'database'})
    menu.add(:trackers, I18n.t(:link_trackers), {controller: 'trackers', action: 'index'}, {id: 'menu-trackers', glyph: 'issue-opened'})
    menu.add(:issues_statuses, I18n.t(:link_issues_statuses), {controller: 'issues_statuses', action: 'index'}, {id: 'menu-issues-statuses', glyph: 'dashboard'})
  end

  Rorganize::Managers::MenuManager.map :top_menu do |menu|
    menu.add(:projects, I18n.t(:label_project_plural), {controller: 'projects', action: 'index'}, {id: 'menu-projects'})
    menu.add(:administration, I18n.t(:link_administration), {controller: 'administration', action: 'index'}, {id: 'menu-administration'})
  end


  Rorganize::Managers::PermissionManager.initialize
  Rorganize::Managers::IssueStatusesColorManager.initialize
  require 'module_configuration'
  require 'permissions_configuration'


  Rorganize::Managers::PluginManager.load
  Rorganize::Managers::ModuleManager.load_modules
end

