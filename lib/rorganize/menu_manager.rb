# Author: Nicolas Meylan
# Date: 9 févr. 2013
# Encoding: UTF-8
# File: menu_manager.rb

module Rorganize
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
        if project
          unless project.identifier.nil?
            return true
          end
        end
        return false
      end

      def render_menu(project = nil)
        if @menu_context.include?(:project_menu)
          render_project_menu(Rorganize::MenuManager.items(:project_menu), project)
        elsif @menu_context.include?(:admin_menu)
          render_admin_menu(Rorganize::MenuManager.items(:admin_menu))
        end

      end

      def render_project_menu(menu, project)
        content = ""
        menu.menu_items.each do |item|
          if current_user.allowed_to?(item.url[:action], item.url[:controller],project)
            item.url[:project_id] = project.identifier
            content += content_tag(:li,
              link_to(item.label, item.url, {:id => item.params[:id]}),
              :class => item.params[:id].eql?(@current_menu_item) ? "selected" :"" )
          end
        end
        content_for :main_menu, content.html_safe
      end

      def render_admin_menu(menu)
        content = ""
        menu.menu_items.each do |item|
          if current_user.allowed_to?(item.url[:action], item.url[:controller])
            content += content_tag(:li,
              link_to(item.label, item.url, {:id => item.params[:id]}),
              :class => item.params[:id].eql?(@current_menu_item) ? "selected" :"" )
          end
        end
        content_for :main_menu, content.html_safe
      end

      def render_top_menu
        menu = Rorganize::MenuManager.items(:top_menu)
        content = ""
        content += content += content_tag(:li,
             link_to(t(:home), :root))
        menu.menu_items.each do |item|
          if current_user && current_user.allowed_to?(item.url[:action], item.url[:controller])
            content += content_tag(:li,
              link_to(item.label, item.url, {:id => item.params[:id]}))
          end
        end
        content_for :top_menu_items, content.html_safe
      end
    end

    #Rorganize::MenuManager class
    class << self
      def map(menu_name)
        @items ||= {}
        if !self.items(menu_name)
          menu = Menu.new(menu_name)
          @items[menu_name] = menu
          yield menu
        else
          yield self.items(menu_name)
        end
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
        raise "item not founded, please check your initializer files. Don't use it inside core_application initializer"
      end
    end
    #Menu item class
    class MenuItem
      attr_reader :name, :label, :url, :params
      def initialize(name, label, url={}, options={})
        @name = name
        @label = label
        @url = url
        @params = options
        if(url[:action] && url[:controller])
          @url[:action] = url[:action]
          @url[:controller] = url[:controller]
        else
          raise "url param must have this structure : {:action => 'action', :controller => 'controller'}"
        end
      end
    end
  end
end
