# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: issue_dates_validator.rb
module Rorganize
  module Models
    module Users
      module Authorization
        # @param [String] action : the action that user want to perform.
        # @param [String] controller : the controller concern by the action.
        # @param [Project] project the context of the action.
        def allowed_to?(action, controller, project = nil)
          return true if admin_free_access(action, controller, project)
          if self.id.eql?(AnonymousUser::ANON_ID) #Concern unconnected users.
            anonymous_allowed_to?(action, controller, project)
          else
            members = self.members
            signed_in_user_allowed_to?(action, controller, members, project)
          end
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
            members.detect { |member| permission_manager_allowed_to?(member.role_id.to_s, action.to_s, controller.downcase.to_s) }
          else
            non_member_permission_manager_allowed_to?(action.to_s, controller.downcase.to_s)
          end
        end

        def in_project_allowed_to?(action, controller, members, project)
          member = members.to_a.detect { |mb| mb.project_id == project.id }
          if member
            generic_permission_condition(action, controller, project) && permission_manager_allowed_to?(member.role_id.to_s, action.to_s, controller.downcase.to_s)
          else
            generic_permission_condition(action, controller, project) && non_member_permission_manager_allowed_to?(action.to_s, controller.downcase.to_s)
          end
        end

        def anonymous_allowed_to?(action, controller, project)
          if project
            generic_permission_condition(action, controller, project) && anonymous_permission_manager_allowed_to?(action.to_s, controller.downcase.to_s)
          else
            anonymous_permission_manager_allowed_to?(action.to_s, controller.downcase.to_s)
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