# Author: Nicolas Meylan
# Date: 22.01.15 20:53
# Encoding: UTF-8
# File: custom_http_request.rb

module Rorganize
  module CustomHttpRequest
    ACTIONS_ALIASES = {'update' => 'edit', 'create' => 'new', 'toolbox' => 'edit'}

    # Simulate a GET request with the given parameters. But add permission to the current user to perform the action.
    # Otherwise user will get a 403 error.
    # See +get+ for more details.
    def get_with_permission(action, *args)
      allow_user_to(action)
      _get(action, *args)
    end

    # Simulate a POST request with the given parameters. But add permission to the current user to perform the action.
    # Otherwise user will get a 403 error.
    # See +get+ for more details.
    def post_with_permission(action, *args)
      allow_user_to(action)
      _post(action, *args)
    end

    # Simulate a PATCH request with the given parameters. But add permission to the current user to perform the action.
    # Otherwise user will get a 403 error.
    # See +get+ for more details.
    def patch_with_permission(action, *args)
      allow_user_to(action)
      _patch(action, *args)
    end

    # Simulate a PUT request with the given parameters. But add permission to the current user to perform the action.
    # Otherwise user will get a 403 error.
    # See +get+ for more details.
    def put_with_permission(action, *args)
      allow_user_to(action)
      _put(action, *args)
    end

    # Simulate a DELETE request with the given parameters. But add permission to the current user to perform the action.
    # Otherwise user will get a 403 error.
    # See +get+ for more details.
    def delete_with_permission(action, *args)
      allow_user_to(action)
      _delete(action, *args)
    end

    # Simulate a GET request with the given parameters. But merge project context params.
    def _get(action, *args)
      args = merge_project_context_params(args)
      get(action, *args)
    end

    # Simulate a POST request with the given parameters. But merge project context params.
    def _post(action, *args)
      args = merge_project_context_params(args)
      post(action, *args)
    end

    # Simulate a PATCH request with the given parameters. But merge project context params.
    def _patch(action, *args)
      args = merge_project_context_params(args)
      patch(action, *args)
    end

    # Simulate a PUT request with the given parameters. But merge project context params.
    def _put(action, *args)
      args = merge_project_context_params(args)
      put(action, *args)
    end

    # Simulate a DELETE request with the given parameters. But merge project context params.
    def _delete(action, *args)
      args = merge_project_context_params(args)
      delete(action, *args)
    end

    def merge_project_context_params(args)
      if @project
        if args.first
          args.first.merge!({project_id: @project.slug})
        else
          args = [{project_id: @project.slug}]
        end
      end
      args
    end

    def allow_user_to(action)
      if @project
        role = User.current.member_for(@project.id).role
      else
        random_member = User.current.members.first
        role = random_member.role
      end
      action = action.to_s
      permission_action = ACTIONS_ALIASES[action]
      permission_action ||= action
      role.permissions << Permission.create(action: permission_action, controller: @controller.controller_name, name: 'dont care')
      role.save
      Rorganize::Managers::PermissionManager::reload_permissions
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