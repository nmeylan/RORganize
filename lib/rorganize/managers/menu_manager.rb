# Author: Nicolas Meylan
# Date: 9 févr. 2013
# Encoding: UTF-8
# File: menu_manager.rb

module Rorganize
  module Managers
    module MenuManager
      module MenuHelper
        def display_menu?(project = nil)
          if @menu_context
            if @menu_context.include?(:project_menu)
              display_project_menu?(project)
            elsif @menu_context.include?(:admin_menu)
              true
            end
          end
        end

        def display_project_menu?(project)
          project && project.slug
        end

        # Select which main menu to render.
        # @param [Project] project.
        def render_menu(project = nil)
          if @menu_context.include?(:project_menu)
            render_main_menu(Rorganize::Managers::MenuManager.items(:project_menu), project)
          elsif @menu_context.include?(:admin_menu)
            render_main_menu(Rorganize::Managers::MenuManager.items(:admin_menu), nil)
          end
        end

        # Render main menu.
        # @param [Menu] menu.
        # @param [Project] project.
        def render_main_menu(menu, project)
          content_for :main_menu do
            menu.menu_items.collect do |item|
              render_main_menu_item(item, project) if allowed_to_view_menu_item?(item, project)
            end.join.html_safe
          end
        end

        # Render a main menu item.
        # @param [MenuItem] item
        # @param [Project] project
        def render_main_menu_item(item, project)
          css_selection = item.params[:id].eql?(@current_menu_item) ? 'selected' : ''
          css_class = item.params[:class] ? "#{item.params[:class]} #{css_selection}" : css_selection
          glyph = glyph(item.label, item.params[:glyph])
          item.url[:project_id] = project.slug if project
          content_tag(:li, link_to(glyph, item.url, {id: item.params[:id]}), class: css_class)
        end

        # Is user allowed to view this menu item in the menu bar?
        # @param [MenuItem] item
        # @param [Project] project
        def allowed_to_view_menu_item?(item, project)
          User.current.allowed_to?(item.url[:action], item.url[:controller], project)
        end

        # Render the top menu bar.
        def render_top_menu
          menu = Rorganize::Managers::MenuManager.items(:top_menu)
          content_for :top_menu_items do
            safe_concat content_tag(:li, link_to(t(:home), :root, {class: @current_top_menu_item.eql?('menu-home') ? 'selected square' : 'square'}))
            render_top_menu_items(menu) unless in_devise_context?
          end
        end

        # Render top menu items.
        # @param [Menu] menu.
        def render_top_menu_items(menu)
          safe_concat(menu.menu_items.collect do |item|
            render_top_menu_item(item) if allowed_to_view_top_menu_item?(item)
          end.join.html_safe)
        end

        # @param [MenuItem] item
        def render_top_menu_item(item)
          css_selection = item.params[:id].eql?(@current_top_menu_item) ? 'selected square' : 'square'
          css_class = item.params[:class] ? "#{item.params[:class]} #{css_selection}" : css_selection
          content_tag(:li, link_to(item.label, item.url, {id: item.params[:id], class: css_class}))
        end

        # Is user allowed to view this top menu item in the bar.
        # @param [MenuItem] item
        def allowed_to_view_top_menu_item?(item)
          User.current && User.current.allowed_to?(item.url[:action], item.url[:controller])
        end

        # Is user in devise context (Devise gem). Registration / connection / forgotten password.
        def in_devise_context?
          controller_name.eql?('sessions') || controller_name.eql?('registrations') || controller_name.eql?('passwords')
        end
      end

      #Rorganize::Managers::MenuManager class
      class << self
        def map(menu_name)
          @items ||= {}
          if block_given?
            if !self.items(menu_name)
              menu = Menu.new(menu_name)
              @items[menu_name] = menu
              yield menu
            else
              yield self.items(menu_name)
            end
          end
          @items[menu_name]
        end

        def items(menu_name)
          @items[menu_name.to_sym]
        end
      end
      #Menu class
      class Menu
        attr_reader :menu, :menu_items

        def initialize(menu_name)
          @menu = menu_name
          @menu_items = []
        end

        #options are
        # id: for html element
        # before : to place an item before another one
        # after : to place an item after another one
        def add(name, label, url={}, options={})
          menu_item = MenuItem.new(name, label, url, options)
          if options[:before]
            position = position_of(options[:before])
            @menu_items.insert(position - 1, menu_item)
          elsif options[:after]
            position = position_of(options[:after])
            @menu_items.insert(position + 1, menu_item)
          else
            @menu_items.push(menu_item)
          end
        end

        def position_of(menu_item_name)
          i = 0
          @menu_items.each do |menu_item|
            if menu_item.name.eql?(menu_item_name.to_sym)
              return i
            end
            i += 1
          end
          raise "item not found, please check your initializer file. Don't use it inside core_application initializer"
        end
      end
      #Menu item class
      class MenuItem
        attr_reader :name, :label, :url, :params, :controller, :action

        def initialize(name, label, url={}, options={})
          @name = name
          @label = label
          @controller = url[:controller]
          @action = url[:action]
          @url = url
          @params = options
          if url[:action] && url[:controller]
            @url[:action] = url[:action]
            @url[:controller] = url[:controller]
          else
            raise "url param must have this structure : {action: 'action', controller: 'controller'}"
          end
        end
      end
    end
  end
end
