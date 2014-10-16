# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: collection_helper.rb
module Rorganize
  module Helpers
    module CollectionHelper
      #Define pagination for the given collection : session is the current selected per_page item, path is the path of the controller.
      # @param [Enumerable] collection : the collection of items to display.
      # @param [Session] session : the per_page argument for pagination.
      # @param [String] path : to the controller to refresh the list when user change the per_page or current_page parameter.
      def paginate(collection, session, path)
        safe_concat will_paginate(collection, {renderer: 'RemoteLinkRenderer', next_label: t(:label_next), previous_label: t(:label_previous)})
        pagination_per_page(path, session)
      end

      # @param [String] path : to the controller to refresh the list when user change the per_page or current_page parameter.
      # @param [Session] session : the per_page argument for pagination.
      def pagination_per_page(path, session)
        content_tag :div, class: 'autocomplete-combobox nosearch per-page autocomplete-combobox-high' do
          safe_concat content_tag :label, t(:label_per_page), {for: 'per_page', class: 'per-page'}
          safe_concat select_tag 'per_page', pagination_options_tag(session), class: 'chzn-select cbb-small cbb-high', id: 'per-page', 'data-link' => "#{path}"
        end
      end

      # @param [Session] session : the per_page argument for pagination.
      def pagination_options_tag(session)
        options_for_select([%w(25 25), %w(50 50), %w(100 100)], session[:per_page])
      end

      # Build a sort link for table.
      # @param [String] column.
      # @param [String] title : if provide replace the default column name.
      # @param [String] default_action : when link is clicked it will send an ajax query to the given default_action. (defaults 'index').
      def sortable(column, title = nil, default_action = nil)
        default_action ||= 'index'
        title ||= column.titleize
        icon = if column == sort_column then
                 sort_direction == 'asc' ? 'triangle-up' : 'triangle-down'
               else
                 ''
               end
        direction = column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
        link_to glyph(title, icon), {sort: column, direction: direction, action: default_action}, {remote: true}
      end
      # Build a list of issues.
      # @param [Array] collection of issues.
      def generic_list(collection, options = {})
        content_tag :table, options do
          safe_concat list_header
          safe_concat list_body(collection)
        end
      end

      def list_body(collection)
        collection.collect do |element|
          list_row(element)
        end.join.html_safe
      end

      # @param [Array] collection that containing the element to sort.
      # @param [SmartRecord] element to sort.
      def list_sort_actions(collection, element)
        content_tag :td, {class: 'action'}, &Proc.new {
          safe_concat element.inc_position_link
          safe_concat element.dec_position_link(collection.size)
        }
      end

      def list_td(content, options = {})
        if block_given?
          safe_concat content_tag :td, options, &Proc.new
        else
          safe_concat content_tag :td, content, options
        end

      end

      def list_th(content, options = {})
        safe_concat content_tag :th, content, options
      end

      def collection_one_column_renderer(collection, class_name, sort_attribute)
        content_tag :table, class: "#{class_name} list" do
          safe_concat collection_one_column_header(sort_attribute)
          safe_concat collection_one_column_body(collection, class_name)
        end
      end
      def collection_one_column_body(collection, class_name)
        collection.collect do |decorated_object|
          collection_one_column_row(decorated_object, class_name)
        end.join.html_safe
      end

      def collection_one_column_row(decorated_object, class_name)
        content_tag :tr, {class: 'odd-even', id: %Q(#{class_name}-#{decorated_object.id})} do
          list_td decorated_object.edit_link, class: 'name'
          list_td decorated_object.delete_link, class: 'action'
        end
      end

      def collection_one_column_header(sort_attribute)
        content_tag :thead do
          content_tag :tr, class: 'header' do
            list_th sortable(sort_attribute, t(:field_name)), class: 'list-left'
            list_th nil
          end
        end
      end

    end
  end
end