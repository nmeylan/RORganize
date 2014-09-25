# Author: Nicolas Meylan
# Date: 8 mai 2013
# Encoding: UTF-8
# File: module_configuration.rb

#TODO refactor string by symboles
#These module are always enabled.
always_enabled_module = [{controller: 'settings', action: 'index'},
                         {controller: 'members', action: 'index'},
                         {controller: 'time_entries', action: 'index'},
                         {controller: 'categories', action: 'index'},
                         {controller: 'wiki_pages', action: 'index'},
                         {controller: 'versions', action: 'index'},
                         {controller: 'queries', action: 'index'},
                         {controller: 'projects', action: 'archive'},
                         {controller: 'projects', action: 'destroy'},
                         {controller: 'projects', action: 'overview'},
                         {controller: 'projects', action: 'watch'},
                         {controller: 'comments', action: 'edit_comment_not_owner'},
                         {controller: 'comments', action: 'destroy_comment_not_owner'}
]


Rorganize::Managers::ModuleManager.initialize_modules(always_enabled_module)

#There is two cases for module activation :
#General case : All actions from a same controller are associated to one MENU and MODULE.
#This is the case when the "index" action (from controller) is used as root action for the controller.
#E.g : issues_controller

#Specifica case: Actions from a same controller are associated to different MENU and MODULE.
#This is the case when an action (other than "index") is used as root action for controller.
#E.g : show action from roadmaps_controller.
#So we have to associated other actions (all excepted show (from previous example)) to a module.

association_actions_module = {
    'roadmaps' => {'roadmaps' => ['manage_gantt', 'gantt']}
}
Rorganize::Managers::ModuleManager.set_associations_actions_module(association_actions_module)

#Modules enabled by default (on project creation)
modules = [{:controller => 'projects', :action => 'activity', :name => 'activity'},
           {:controller => 'roadmaps', :action => 'show', :name => 'roadmaps'},
           {:controller => 'issues', :action => 'index', :name => 'requests'}]
Rorganize::Managers::ModuleManager.set_enabled_by_default_module(modules)
