# Author: Nicolas Meylan
# Date: 23 mars 2013
# Encoding: UTF-8
# File: module_manager.rb

module Rorganize
  module Managers
    module ModuleManager
      module ModuleManagerHelper
        # TODO rename add suffix "_for_project"
        def module_enabled?(project_id, action, controller)
          always_enabled_modules = Rorganize::Managers::ModuleManager.always_enabled_modules
          if is_an_always_enabled_module?(action, always_enabled_modules, controller)
            return true
          end
          Rorganize::Managers::ModuleManager.panel(:project).enabled_modules[project_id.to_s].each do |m|
            association = Rorganize::Managers::ModuleManager.associations[m[:name]]
            controller = controller.downcase
            action = action.downcase
            if is_module_enabled?(action, association, controller, m)
              return true
            end
          end
          false
        end

        def is_module_enabled?(action, association, controller, m)
          (m[:controller].eql?(controller) && m[:action].eql?('index')) ||
              (m[:controller].eql?(controller) && m[:action].eql?(action)) ||
              (association && association[controller] && association[m[:controller]].include?(action))
        end

        def is_an_always_enabled_module?(action, always_enabled_modules, controller)
          always_enabled_modules.any? do |mod|
            (mod[:controller].eql?(controller.downcase) && mod[:action].eql?('index')) ||
                (mod[:controller].eql?(controller.downcase) && mod[:action].eql?(action.downcase))
          end
        end
      end

      class << self
        attr_reader :associations, :enabled_by_default_modules, :always_enabled_modules
        # @param [Symbol] module_panel_name the panel identifier.
        def map(module_panel_name)
          @panels ||= {}
          if !self.panel(module_panel_name)
            @panels[module_panel_name] = Panel.new(module_panel_name)
            yield @panels[module_panel_name]
          else
            yield self.panel(module_panel_name)
          end
        end

        def panel(module_name)
          @panels[module_name.to_sym]
        end

        # It set an association for a given modules to given controller#actions
        # @param [Hash] associations_hash : a hash with this structure :
        # {
        #   module_name:String => {controller_name:String => actions:Array[String]}
        # }
        def set_associations_actions_module(associations_hash)
          if @associations.nil?
            @associations = associations_hash
          else
            @associations.merge!(associations_hash)
          end
        end

        # @param [Array[Hash]] always_enabled_module : all always enabled controller#action.
        def initialize_modules(always_enabled_modules)
          @enabled_by_default_modules = []
          @always_enabled_modules = always_enabled_modules
        end

        def load_project_panel_modules
          Rorganize::Managers::ModuleManager.map :project do |mod|
            Rorganize::Managers::MenuManager.menu(:project_menu).menu_items.each do |item|
              mod.add(item.name, item.controller, item.action)
            end
          end
        end

        def reload_enabled_modules(project_id)
          Rorganize::Managers::ModuleManager.panel(:project).load_enabled_modules_spec_project(project_id)
        end

        # @param [Array[Hash]] always_enabled_module : all always enabled controller#action.
        def add_always_enabled_modules(always_enabled_module)
          @always_enabled_modules += always_enabled_module
        end

        # @param [Array] modules : enabled by default on project creation.
        def set_enabled_by_default_module(modules)
          @enabled_by_default_modules = modules
        end

        def always_enabled_module
          @always_enabled_modules
        end

        def clear_panel_modules(panel_name)
          panel = panel(panel_name)
          panel.clear_all! if panel
        end
      end

      # Panel class : For the moment only ProjectPanel exists.
      # Should refactor methods when other Panel would be added, but for the moment
      # I can't figure out which panel can be added.
      class Panel
        attr_reader :enabled_modules, :name, :modules

        def initialize(panel_name)
          @name = panel_name
          @modules = []
          @enabled_modules = Hash.new { |h, project_id| h[project_id] = [] }
          load_enabled_modules
        end

        def add(name, controller, action)
          @modules << ModuleItem.new(name, controller, action)
        end

        def load_enabled_modules
          projects = Project.all
          projects.each do |project|
            load_enable_modules_for_given_project(project)
          end
        end

        def load_enabled_modules_spec_project(project_id)
          project = Project.find(project_id)
          @enabled_modules[project_id.to_s].clear
          load_enable_modules_for_given_project(project)
        end

        def load_enable_modules_for_given_project(project)
          project.enabled_modules.each do |mod|
            action = mod.action ? mod.action.downcase : ''
            name = mod.name ? mod.name.downcase : ''
            @enabled_modules[project.id.to_s] << {action: action, controller: mod.controller.downcase, name: name}
          end
        end

        def clear_all_for_project!(project)
          @enabled_modules[project.id.to_s].clear if @enabled_modules[project.id.to_s]
        end

        def clear_all!
          @enabled_modules.clear
          @modules.clear
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
