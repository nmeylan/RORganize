# Author: Nicolas Meylan
# Date: 9 févr. 2013
# Encoding: UTF-8
# File: rorganize.rb

require 'rorganize/menu_manager'
require 'rorganize/module_manager'
require 'rorganize/permission_manager'

module Rorganize
  TIME_FORMAT = '%a. %-d %b. %I:%M %p.'
  ACTION_ICON = {version_id: 'milestone', due_date: 'today', assigned_to_id: 'person', status_id: 'dashboard', category_id: 'tag', done: 'pulse', tracker_id: 'issue-opened', admin: 'crown', email: 'mail'}
  NON_MEMBER_ROLE = 'Non member'
end

unless $0.end_with?('rake')
  I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
  Rorganize::MenuManager.map :project_menu do |menu|
    #menu.add(module_name, menu_url, options)
    #module_name : is the name of the associated module. Module need to be activate(at settings->module) to perform actions from controller.
    #menu_url must be under hash format and not route_path(..)
    #General case : If you have one menu item per controller
    #   then Client id must be declare as following: menu_controller. All action from this controller will be activate when module module_name is activate.
    #If you want a specific menu for differents actions from a same controller
    #   then Client id must be declare as following: menu_controller_action. However, only these action will be activate(by default) when the module module_name is activate.
    #Here same controller but a menu for both actions :
    menu.add(:overview, I18n.t(:label_overview), {controller: 'projects', action: 'overview'}, {id: 'menu_projects_overview', glyph: 'repo'})
    menu.add(:activity, I18n.t(:label_activity), {controller: 'projects', action: 'activity'}, {id: 'menu_projects_activity', glyph: 'rss'})
    #Same here
    menu.add(:roadmaps, I18n.t(:label_roadmap), {controller: 'roadmaps', action: 'show'}, {id: 'menu_roadmaps', glyph: 'milestone'})
    #One menu for all action from issues_controller
    menu.add(:requests, I18n.t(:label_request_plural), {controller: 'issues', action: 'index'}, {id: 'menu_issues', glyph: 'issue-opened'})
    menu.add(:documents, I18n.t(:label_documents), {controller: 'documents', action: 'index'}, {id: 'menu_documents', glyph: 'file-text'})
    menu.add(:wiki, I18n.t(:label_wiki), {controller: 'wiki', action: 'index'}, {id: 'menu_wiki', glyph: 'book'})
    menu.add(:settings, I18n.t(:label_setting_plural), {controller: 'settings', action: 'index'}, {id: 'menu_settings', glyph: 'tools'})
  end

  Rorganize::MenuManager.map :admin_menu do |menu|
    menu.add(:permissions, I18n.t(:link_permissions), {controller: 'permissions', action: 'index'}, {id: 'menu_permissions', glyph: 'key'})
    menu.add(:roles, I18n.t(:link_roles), {controller: 'roles', action: 'index'}, {id: 'menu_roles', glyph: 'person'})
    menu.add(:users, I18n.t(:link_users), {controller: 'users', action: 'index'}, {id: 'menu_users', glyph: 'organization'})
    menu.add(:queries, I18n.t(:link_queries), {controller: 'administration', action: 'public_queries'}, {id: 'menu_administration_public_queries', glyph: 'database'})
    menu.add(:trackers, I18n.t(:link_trackers), {controller: 'trackers', action: 'index'}, {id: 'menu_trackers', glyph: 'issue-opened'})
    menu.add(:issues_statuses, I18n.t(:link_issues_statuses), {controller: 'issues_statuses', action: 'index'}, {id: 'menu_issues_statuses', glyph: 'dashboard'})
  end

  Rorganize::MenuManager.map :top_menu do |menu|
    menu.add(:projects, I18n.t(:label_project_plural), {controller: 'projects', action: 'index'}, {id: 'menu_projects'})
    menu.add(:administration, I18n.t(:link_administration), {controller: 'administration', action: 'index'}, {id: 'menu_administration'})
  end


  Rorganize::PermissionManager.initialize
end