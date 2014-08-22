# Author: Nicolas Meylan
# Date: 23 mars 2013
# Encoding: UTF-8
# File: permissions.rb

module Rorganize
  module PermissionManager

    module PermissionHandler
      #Params hash content:
      #method : possible values :post, :get , :put, :delete
      #target : possible values "nil" or "self", if self url will be '#' else will be path
      #html = {}
      def link_to_with_permissions(label, path, project, owner_id, params = {})
        routes = Rails.application.routes
        hash_path = routes.recognize_path(path, :method => params[:method])
        unless params[:confirm].nil?
          params[:data] ||= {}
          params[:data][:confirm] = params[:confirm].clone
          params[:confirm] = nil
        end
        if (owner_id.nil? && User.current.allowed_to?(hash_path[:action], hash_path[:controller], project)) || (!owner_id.nil? && (User.current.allowed_to?(hash_path[:action], hash_path[:controller], project) && owner_id.eql?(User.current.id) ||
            User.current.allowed_to?("#{hash_path[:action]}_not_owner", hash_path[:controller], project)))
          if params[:target] && params[:target].eql?('self')
            h.link_to(label, '#', params)
          else
            h.link_to(label, path, params)
          end
        end
      end

    end

    module PermissionManagerHelper
      def permission_manager_allowed_to?(role_id, action, controller)
        Rorganize::PermissionManager.permissions[role_id].any? { |permission| permission[:action] == action && permission[:controller] == controller }
      end

      def reload_permission(role_id)
        Rorganize::PermissionManager.load_permissions_spec_role(role_id)
      end

      def allowed_to_actions_list(role_id, controller = nil)
        controller ? Rorganize::PermissionManager.permissions[role_id].select { |permission| permission[:controller] == controller } : Rorganize::PermissionManager.permissions[role_id]
      end

      def project_archive_permissions(action, controller)
        permissions = Hash.new { |h, k| h[k] = [] }
        permissions['action'] = %w(new edit create update destroy delete checklist change)
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

    class << self
      attr_reader :permissions

      def initialize
        @permissions = load_permissions
      end

      def reload_permissions
        @permissions = load_permissions
      end

      def load_permissions
        roles = Role.all
        permissions = Hash.new { |h, k| h[k] = [] }
        roles.each do |role|
          permissions[role.id.to_s] = []
          role.permissions.each do |permission|
            permissions[role.id.to_s] << {:action => permission.action, :controller => permission.controller.downcase}
          end
        end
        return permissions
      end

      def load_permissions_spec_role(role_id)
        role = Role.find(role_id)
        @permissions[role_id.to_s].clear
        role.permissions.each do |perm|
          @permissions[role_id.to_s] << {:action => perm.action, :controller => perm.controller.downcase}
        end
      end

    end
  end
end
