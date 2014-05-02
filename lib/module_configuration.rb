# Author: Nicolas Meylan
# Date: 8 mai 2013
# Encoding: UTF-8
# File: module_configuration.rb

#These module can't be disabled.
always_enabled_module = [{:controller => 'settings', :action => 'index'},
  {:controller => 'members', :action => 'index'},
  {:controller => 'categories', :action => 'index'},
  {:controller => 'wiki_pages', :action => 'index'},
  {:controller => 'versions', :action => 'index'},
  {:controller => 'queries', :action => 'index'},
  {:controller => 'projects', :action => 'archive'},
  {:controller => 'projects', :action => 'destroy'},
  {:controller => 'projects', :action => 'overview'},
  {:controller => 'coworkers', :action => 'index'}
]

Rorganize::ModuleManager.initialize_modules(always_enabled_module)
