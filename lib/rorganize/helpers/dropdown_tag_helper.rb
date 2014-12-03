# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: filter_helper.rb

# I use raw html instead of content_tag due to performance issues.
# I reduce by 150% the render time when I have to render over 2000 dropdown tag.
module Rorganize
  module Helpers
    module DropdownTagHelper
      def dropdown_tag(menu_content = nil, type = :span, &block)
        "<#{type} class='dropdown'>
          #{dropdown_link}
          #{dropdown_content(menu_content, &block)}
        </#{type}>"
      end

      # Draw a link for dropdown : don't use link-to because it is too slow.
      def dropdown_link
        "<a href='#' class='dropdown-link', data-toggle='dropdown'><span class='dropdown-caret'></span></a>"
      end

      def dropdown_caret
        "<span class='dropdown-caret'></span>"
      end

      def dropdown_content(menu_content)
        "<div class='dropdown-menu-content'>
          <ul class='dropdown-menu'>
            #{block_given? ? yield : menu_content}
          </ul>
        </div>"
      end

      def dropdown_row(content = nil)
        "<li>#{block_given? ? yield : content}</li>"
      end

    end
  end
end