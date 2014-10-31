# Author: Nicolas Meylan
# Date: 30.10.14
# Encoding: UTF-8
# File: plugin_manager.rb
module Rorganize
  module Managers
    module PluginManager
      class PluginNotFound < StandardError;
      end

      class << self
        cattr_accessor :directory
        self.directory = File.join(Rails.root, 'vendor', 'engines')

        cattr_reader :registered_plugins
        @@registered_plugins = {}

        def register(id, &block)
          plugin = Plugin.new(id)
          yield plugin
          plugin.directory = File.join(self.directory, id.to_s) if plugin.directory.nil?
          Rails.application.config.i18n.load_path += Dir.glob(File.join(plugin.directory, 'config', 'locales', '*.yml'))
          Dir.glob File.expand_path(File.join(plugin.directory, 'app', '{decorators}')) do |dir|
            ActiveSupport::Dependencies.autoload_paths += [dir]
          end

          @@registered_plugins[id.to_sym] = plugin
        end

        def all
          @@registered_plugins.values.sort
        end

        # Finds a plugin by its id
        # Returns a PluginNotFound exception if the plugin doesn't exist
        def find(id)
          @@registered_plugins[id.to_sym] || raise(PluginNotFound)
        end

        def load
          Dir.glob(File.join(self.directory, '*')).sort.each do |directory|
            if File.directory?(directory)
              mount_engine(directory)
            end
          end
        end


        def mount_engine(directory)
          lib = File.join(directory, 'lib')
          if File.directory?(lib)
            $:.unshift lib
            ActiveSupport::Dependencies.autoload_paths += [lib]
          end
          initializer = File.join(directory, 'init.rb')
          require initializer if File.file?(initializer)
        end

      end

      class Plugin
        attr_accessor :id, :directory, :version, :url, :author, :description, :summary, :name

        def initialize(id)
          @id = id
        end

        def menu(menu, name, label, url, options={})
          Rorganize::Managers::MenuManager.map(menu).add(name, label, url, options)
        end

        def add_to_always_enabled_modules(always_enabled_modules)
          Rorganize::Managers::ModuleManager.add_always_enabled_modules(always_enabled_modules)
        end

        def add_modules_associations(association_actions_module)
          Rorganize::Managers::ModuleManager.set_associations_actions_module(association_actions_module)
        end
      end
    end
  end
end