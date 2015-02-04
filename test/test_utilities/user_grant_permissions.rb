# Author: Nicolas Meylan
# Date: 22.01.15 20:53
# Encoding: UTF-8
# File: custom_http_request.rb

module Rorganize
  module UserGrantPermissions
    ACTIONS_ALIASES = {'update' => 'edit', 'create' => 'new', 'toolbox' => 'edit'}

    def allow_user_to(action, controller = nil)
      if @project
        role = User.current.member_for(@project.id).role
      else
        random_member = User.current.members.first
        role = random_member.role
      end
      action = permission_action(action)
      controller = controller ? controller : @controller.controller_name
      role.permissions << Permission.create(action: action, controller: controller, name: 'dont care')
      role.save
      Rorganize::Managers::PermissionManager::reload_permissions
    end

    def permission_action(action)
      action = action.to_s
      permission_action = ACTIONS_ALIASES[action]
      permission_action ||= action
    end

    def drop_all_user_permissions
      if @project
        role = User.current.member_for(@project.id).role
      else
        random_member = User.current.members.first
        role = random_member.role
      end
      role.permissions.clear
      role.save
      Rorganize::Managers::PermissionManager::reload_permissions
    end
  end
end