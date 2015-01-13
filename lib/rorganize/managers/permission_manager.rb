# Author: Nicolas Meylan
# Date: 23 mars 2013
# Encoding: UTF-8
# File: permissions.rb

module Rorganize
  module Managers
    module PermissionManager

      module PermissionHandler
        include Rorganize::Managers::UrlManager
        #Params hash content:
        #method : possible values :post, :get , :put, :delete
        #target : possible values "nil" or "self", if self url will be '#' else will be path
        #html = {}
        def link_to_with_permissions(label, path, project, owner_id, params = {})
          permission_checker(path, project, owner_id, params) do
            if params[:target] && params[:target].eql?('self')
              params.delete_if { |k, _| k.eql?(:method) && params[:remote].nil? || params[:target] }
              link_to(label, '#', params)
            else
              link_to(label, path, params)
            end
          end
        end

        def button_to_with_permissions(label, path, project, owner_id, params = {})
          permission_checker(path, project, owner_id, params) do
            button_to label, path, params
          end
        end

        def permission_checker(path, project, owner_id, params = {})
          hash_path = recognize_path(path, method: params[:method])
          unless params[:confirm].nil?
            params[:data] ||= {}
            params[:data][:confirm] = params[:confirm].clone
            params[:confirm] = nil
          end
          if allowed_to_without_owner_check?(hash_path, owner_id, project) ||
              allowed_to_with_owner_check?(hash_path, owner_id, project)
            yield
          end
        end

        def allowed_to_without_owner_check?(hash_path, owner_id, project)
          (owner_id.nil? && User.current.allowed_to?(find_action_alias(hash_path[:action]), hash_path[:controller], project))
        end

        def allowed_to_with_owner_check?(hash_path, owner_id, project)
          (!owner_id.nil? && (owner_and_allowed?(hash_path, owner_id, project) || not_owner_and_allowed?(hash_path, project)))
        end

        def not_owner_and_allowed?(hash_path, project)
          User.current.allowed_to?("#{hash_path[:action]}_not_owner", hash_path[:controller], project)
        end

        def owner_and_allowed?(hash_path, owner_id, project)
          User.current.allowed_to?(find_action_alias(hash_path[:action]), hash_path[:controller], project) && owner_id.eql?(User.current.id)
        end

        def find_action_alias(action)
          if Rorganize::Managers::PermissionManager.aliases.keys.include?(action)
            Rorganize::Managers::PermissionManager.aliases[action]
          else
            action
          end
        end
      end

      module PermissionManagerHelper
        def permission_manager_allowed_to?(role_id, action, controller)
          Rorganize::Managers::PermissionManager.permissions[role_id.to_s].any? do |permission|
            permission[:action] == action.to_s.downcase && permission[:controller] == controller.to_s.downcase
          end
        end

        def non_member_permission_manager_allowed_to?(action, controller)
          non_member_role = Rorganize::Managers::PermissionManager.non_member_role
          permission_manager_allowed_to?(non_member_role.id, action, controller)
        end

        def anonymous_permission_manager_allowed_to?(action, controller)
          anonymous_role = Rorganize::Managers::PermissionManager.anonymous_role
          permission_manager_allowed_to?(anonymous_role.id, action, controller)
        end

        def reload_permission(role_id)
          Rorganize::Managers::PermissionManager.load_permissions_spec_role(role_id)
        end

        def allowed_to_actions_list(role_id, controller = nil)
          controller ? Rorganize::Managers::PermissionManager.permissions[role_id].select { |permission| permission[:controller] == controller } : Rorganize::Managers::PermissionManager.permissions[role_id]
        end

        def project_archive_permissions(action, controller)
          permissions = Hash.new { |h, k| h[k] = [] }
          permissions['action'] = %w(new edit create update destroy delete change)
          permissions['controller'] = %w(Categories Versions)
          if permissions['controller'].include?(controller)
            return false
          end
          permissions['action'].each do |a|
            if action.include?(a)
              return false
            end
          end
          true
        end
      end

      module PermissionListCreator
        def load_controllers
          controllers = Rails.application.routes.routes.collect { |route| route.defaults[:controller] }
          controllers += Rails::Engine.subclasses.collect do |engine|
            engine.routes.routes.collect { |route| route.defaults[:controller] }
          end.flatten
          controllers = controllers.uniq!.select { |controller_name| controller_name && !controller_name.match(/.*\/.*/) }
          result_group = nil
          controllers_hash = {project: [], administration: [], misc: []}
          controllers.collect do |controller|
            Rorganize::Managers::PermissionManager.controllers_groups.each do |group, ctrls|
              if ctrls.include?(controller)
                result_group = group
                break
              end
            end
            controllers_hash[result_group.nil? ? :misc : result_group] << controller.capitalize
            result_group = nil
          end
          controllers_hash
        end
      end

      class << self
        attr_reader :permissions, :anonymous_role, :non_member_role, :aliases, :controllers_groups

        def initialize
          @permissions = load_permissions
          @anonymous_role = Role.find_by_name('Anonymous')
          @non_member_role = Role.find_by_name('Non member')
          @aliases = {'update' => 'edit', 'create' => 'new', 'toolbox' => 'edit'}
          @controllers_groups = {project: [], administration: [], misc: []}
        end

        def reload_permissions
          @permissions = load_permissions
        end

        def load_permissions
          roles = Role.all
          roles.inject(Hash.new { |h, k| h[k] = [] }) do |memo, role|
            memo[role.id.to_s] = role_permissions_hash(role)
            memo
          end
        end

        def role_permissions_hash(role)
          role.permissions.inject([]) do |memo_perm, permission|
            memo_perm << {action: permission.action.downcase, controller: permission.controller.downcase}
            memo_perm
          end
        end

        def load_permissions_spec_role(role_id)
          role = Role.find(role_id)
          @permissions[role_id.to_s].clear
          @permissions[role_id.to_s] = role_permissions_hash(role)
        end

        def set_controllers_groups(controllers_groups)
          @controllers_groups = controllers_groups
        end

      end
    end
  end
end
