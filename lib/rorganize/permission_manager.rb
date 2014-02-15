# Author: Nicolas Meylan
# Date: 23 mars 2013
# Encoding: UTF-8
# File: permissions.rb

module Rorganize
  module PermissionManager

    module PermissionManagerHelper
      def permission_manager_allowed_to?(role_id,action, controller)
        return Rorganize::PermissionManager.permissions[role_id].any?{|permission| permission[:action] == action && permission[:controller] == controller}
      end

      def reload_permission(role_id)
        Rorganize::PermissionManager.load_permissions_spec_role(role_id)
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
        permissions = Hash.new{|h, k| h[k] = []}
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
