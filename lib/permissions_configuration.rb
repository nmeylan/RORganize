# Author: Nicolas Meylan
# Date: 05.09.14
# Encoding: UTF-8
# File: permissions_configuration.rb

#Here you have to define your controllers groups.
#There are 3 groups :
# project
# administration
# misc

#These groups are used to display the controllers list in the administration panel.
#If no group is provided for a controller, it will be assigned to the misc group by default.
groups = [
    Rorganize::Managers::PermissionManager::ControllerGroup.new(:project, I18n.t(:label_project), 'repo',
                        %w(categories comments documents issues members projects queries roadmaps settings time_entries versions wiki wiki_pages)),

    Rorganize::Managers::PermissionManager::ControllerGroup.new(:administration, I18n.t(:label_administration), 'medium-crown',
                        %w(administration issues_statuses permissions roles trackers users)),

    Rorganize::Managers::PermissionManager::ControllerGroup.new(:misc, I18n.t(:label_misc))
]

Rorganize::Managers::PermissionManager.set_controllers_groups(groups)


module Rorganize
  #Define permissions categories here (only use to group permissions on the list render)
  PERMISSIONS_LIST_COL_CATEGORIES = {read: %w(view access consult use watch show),
                                     create: %w(create add new insert),
                                     update: %w(edit update change organize manage archive log configure restore rank attach detach),
                                     delete: %w(delete destroy remove erase)}
end