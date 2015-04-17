# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: issue_dates_validator.rb
module Rorganize
  module Models
    module Users
      module Authorization
        include Rorganize::Managers::PermissionManager::PermissionManagerHelper
        include Rorganize::Managers::ModuleManager::ModuleManagerHelper

        attr_accessor :checked_permissions
        # @param [String] action : the action that user want to perform.
        # @param [String] controller : the controller concerns by the action.
        # @param [Project] project the context of the action.
        def allowed_to?(action, controller, project = nil)
          hash_key = "#{(project ? project.id : 'nil')}_#{controller}_#{action}".freeze
          self.checked_permissions[hash_key] || unchecked_permissions_verifier(action, controller, project, hash_key)
        end

        def unchecked_permissions_verifier(action, controller, project, hash_key)
          if admin_free_access(action, controller, project)
            checked_permissions[hash_key] = true
            return true
          end
          if self.id.eql?(AnonymousUser::ANON_ID) #Concern unconnected users.
            checked_permission_result = anonymous_allowed_to?(action, controller, project)
          else
            members = self.members
            checked_permission_result = signed_in_user_allowed_to?(action, controller, members, project)
          end
          self.checked_permissions[hash_key] = checked_permission_result
          checked_permission_result
        end

        def signed_in_user_allowed_to?(action, controller, members, project)
          if project
            in_project_allowed_to?(action, controller, members, project)
          else
            out_project_allowed_to?(action, controller, members)
          end
        end

        def admin_free_access(action, controller, project)
          admin_act_as_admin? && (project && module_enabled?(project.id.to_s, action, controller) || !project)
        end

        def admin_act_as_admin?
          self.is_admin? && act_as_admin?
        end

        def out_project_allowed_to?(action, controller, members)
          if members && members.any?
            members.detect { |member| permission_manager_allowed_to?(member.role_id, action, controller.downcase) }
          else
            non_member_permission_manager_allowed_to?(action, controller.downcase)
          end
        end

        def in_project_allowed_to?(action, controller, members, project)
          member = members.to_a.detect { |mb| mb.project_id == project.id }
          if member
            generic_permission_condition(action, controller, project) && permission_manager_allowed_to?(member.role_id, action, controller)
          elsif project.is_public
            generic_permission_condition(action, controller, project) && non_member_permission_manager_allowed_to?(action, controller)
          end
        end

        def anonymous_allowed_to?(action, controller, project)
          if project && project.is_public
            generic_permission_condition(action, controller, project) && anonymous_permission_manager_allowed_to?(action, controller)
          elsif project.nil?
            anonymous_permission_manager_allowed_to?(action, controller)
          end
        end

        def generic_permission_condition(action, controller, project)
          (module_enabled?(project.id.to_s, action, controller) &&
              (!project.is_archived? || (project.is_archived? && project_archive_permissions(action, controller))))
        end

      end
    end
  end
end