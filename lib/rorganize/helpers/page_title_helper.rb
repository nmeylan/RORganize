# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: filter_helper.rb
module Rorganize
  module Helpers
    module PageTitleHelper
      # Dynamic page title depending on context (action / controller)
      # @return [String] page title.
      def title_tag
        title = ''
        if controller_name.eql?('exception')
          title = title_tag_exception_pages(title)
        else
          title = title_tag_context_pages(title)
          title = title_tag_specific_pages(title)
        end
        title
      end

      def title_tag_context_pages(title)
        if @project && !@project.new_record?
          title += @project.slug.capitalize + ' '
        elsif controller_name.eql?('profiles')
          title += User.current.login + " (#{User.current.caption}) "
        else
          title += 'RORganize '
        end
        title
      end

      def title_tag_specific_pages(title)
        if action_name.eql?('activity')
          title += t(:label_activity)
        elsif action_name.eql?('overview')
          title += t(:label_overview)
        elsif controller_name.eql?('rorganize')
          title += t(:home)
        elsif !controller_name.eql?('profiles')
          title += controller_name.capitalize
        end
        title
      end

      def title_tag_exception_pages(title)
        case @status
          when 404
            title += 'Page not found '
          when 403
            title += 'Permissions required '
          else
            title += 'Something went wrong '
        end
        title += '- RORganize'
      end

    end
  end
end