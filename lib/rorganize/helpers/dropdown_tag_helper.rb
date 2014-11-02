# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: filter_helper.rb
module Rorganize
  module Helpers
    module DropdownTagHelper
      def dropdown_tag(menu_content = nil, type = :span, &block)
        content_tag type, {class: 'dropdown'} do
          safe_concat dropdown_link
          safe_concat dropdown_content(menu_content, &block)
        end
      end

      def dropdown_link
        link_to dropdown_caret, '#', { class: 'dropdown-link', 'data-toggle' => 'dropdown'}
      end

      def dropdown_caret
        content_tag :span, nil, {class: 'dropdown-caret'}
      end

      def dropdown_content(menu_content)
        content_tag :div, class: 'dropdown-menu-content' do
          content_tag :ul, class: 'dropdown-menu' do
            if block_given?
              yield
            else
              menu_content
            end
          end
        end
      end

      def dropdown_row(content = nil)
        content_tag :li do
          if block_given?
            yield
          else
            content
          end
        end
      end

    end
  end
end