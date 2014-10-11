# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: toolbox_helper.rb
module Rorganize
  module Helpers
    module ToolboxHelper

      # Build a toolbox render from a toolbox object.
      # @param [Toolbox] toolbox : the toolbox object.
      def toolbox_tag(toolbox)
        form_tag toolbox.path, remote: true, id: 'toolbox-form', &Proc.new {
          safe_concat toolbox_menu_items(toolbox)
          safe_concat toolbox_extra_menu_item(toolbox)
          safe_concat toolbox_hidden_tag(toolbox)
        }
      end

      def toolbox_hidden_tag(toolbox)
        toolbox.collection_ids.collect do |id|
          hidden_field_tag 'ids[]', id
        end.join.html_safe
      end

      def toolbox_extra_menu_item(toolbox)
        toolbox.extra_actions.collect do |action|
          content_tag :li, action
        end.join.html_safe
      end

      def toolbox_menu_items(toolbox)
        toolbox.menu.values.collect do |menu_item|
          toolbox_menu_item(menu_item)
        end.join.html_safe
      end

      # build a toolbox menu.
      # @param [ToolboxMenuItem] menu_item the menu to build.
      def toolbox_menu_item(menu_item)
        content_tag :li do
          safe_concat link_to glyph(menu_item.caption, menu_item.glyph_name), '#', {id: menu_item.name}
          safe_concat content_tag :ul, class: "submenu #{menu_item.attribute_name}", &Proc.new {
            if menu_contains_sub_item?(menu_item)
              safe_concat hidden_field_tag "value[#{menu_item.attribute_name}]"
              safe_concat toolbox_sub_menu_items(menu_item)
              safe_concat toolbox_none_sub_menu_item(menu_item)
            end
          }
        end
      end

      def menu_contains_sub_item?(menu_item)
        menu_item.all && menu_item.all.any?
      end

      # build a toolbox none option sub menu.
      # @param [ToolboxMenuItem] menu_item.
      def toolbox_none_sub_menu_item(menu_item)
        if menu_item.none_allowed
          content_tag :li, link_to(conditional_glyph('None', menu_item.currents.include?(nil), 'check'), '#', {:'data-id' => -1})
        end
      end

      # build sub_menu items for a menu.
      # @param [ToolboxMenuItem] menu_item.
      def toolbox_sub_menu_items(menu_item)
        menu_item.all.collect do |sub_menu_item|
          content_tag :li do
            toolbox_sub_menu_item(sub_menu_item, menu_item)
          end
        end.join.html_safe
      end

      # build a sub menu item for a menu.
      # @param [ActiveRecord::Base] sub_menu_item
      # @param [ToolboxMenuItem] menu_item
      def toolbox_sub_menu_item(sub_menu_item, menu_item)
        caption = sub_menu_item.respond_to?(:caption) ? sub_menu_item.caption : sub_menu_item.to_s
        id = sub_menu_item.respond_to?(:id) ? sub_menu_item.id : sub_menu_item
        link_to(conditional_glyph(caption, menu_item.currents.include?(sub_menu_item), 'check'), '#', {:'data-id' => id})
      end


    end
  end
end