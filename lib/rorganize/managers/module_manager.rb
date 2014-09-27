# Author: Nicolas Meylan
# Date: 23 mars 2013
# Encoding: UTF-8
# File: module_manager.rb

module Rorganize
  module Managers
    module ModuleManager
      module ModuleManagerHelper
        def module_enabled?(project_id, action, controller)
          always_enabled_module = Rorganize::Managers::ModuleManager.always_enabled_module
          if always_enabled_module.any? { |mod| (mod[:controller].eql?(controller.downcase) && mod[:action].eql?('index')) || (mod[:controller].eql?(controller.downcase) && mod[:action].eql?(action.downcase)) }
            return true
          end
          module_is_enabled = false
          Rorganize::Managers::ModuleManager.modules(:project).enabled_modules[project_id].each do |m|
            association = Rorganize::Managers::ModuleManager.associations[m[:name]]
            controller = controller.downcase
            action = action.downcase
            module_is_enabled = (m[:controller].eql?(controller) && m[:action].eql?('index')) ||
                (m[:controller].eql?(controller) && m[:action].eql?(action)) ||
                (association && association[controller] && association[m[:controller]].include?(action))
            if module_is_enabled
              break
            end
          end
          module_is_enabled
        end

        def reload_enabled_module(project_id)
          Rorganize::Managers::ModuleManager.modules(:project).load_enabled_modules_spec_project(project_id)
        end
      end

      class << self
        attr_reader :associations, :enabled_by_default_modules

        def map(module_panel_name)
          @modules ||= {}
          if !self.modules(module_panel_name)
            @modules[module_panel_name] = Module.new(module_panel_name)
            yield @modules[module_panel_name]
          else
            yield self.modules(module_panel_name)
          end
        end

        def modules(module_name)
          @modules[module_name.to_sym]
        end

        def set_associations_actions_module(associations_hash)
          @associations = associations_hash
        end

        def initialize_modules(always_enabled_module)
          @enabled_by_default_modules = []
          @always_enabled_module = always_enabled_module
          Rorganize::Managers::ModuleManager.map :project do |mod|
            Rorganize::Managers::MenuManager.items(:project_menu).menu_items.each do |item|
              mod.add(item.name, item.controller, item.action)
            end
          end
        end

        # @param [Array] modules : enabled by default on project creation.
        def set_enabled_by_default_module(modules)
          @enabled_by_default_modules = modules
        end

        def always_enabled_module
          return @always_enabled_module
        end
      end

      #Module class
      class Module
        attr_reader :enabled_modules, :name, :module_items

        def initialize(panel_name)
          @name = panel_name
          @module_items = []
          @enabled_modules = load_enabled_modules
        end

        def add(name, controller, action)
          module_item = ModuleItem.new(name, controller, action)
          @module_items << module_item
        end

        def load_enabled_modules
          enabled_modules = Hash.new { |h, k| h[k] = [] }
          projects = Project.all
          projects.each do |project|
            project.enabled_modules.each do |mod|
              enabled_modules[project.id.to_s] << {:action => mod.action, :controller => mod.controller.downcase, :name => mod.name}
            end
          end
          return enabled_modules
        end

        def load_enabled_modules_spec_project(project_id)
          project =Project.find(project_id)
          @enabled_modules[project_id.to_s].clear
          project.enabled_modules.each do |mod|
            @enabled_modules[project_id.to_s] << {:action => mod.action, :controller => mod.controller.downcase, :name => mod.name}
          end
        end

        def enabled_module?(action, controller)
          @module_items.each do |m|
            module_is_enabled = (m.controller.eql?(controller.downcase) && m.action.eql?('index')) || (m.controller.eql?(controller.downcase) && m.action.eql?(action.downcase))
            if module_is_enabled
              break
            end
          end
          module_is_enabled = false
        end
      end

      class ModuleItem
        attr_reader :name, :action, :controller

        def initialize(name, controller, action)
          @name = name
          @controller = controller
          @action = action
        end
      end
    end
  end
end