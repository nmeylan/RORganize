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
        elsif controller_name.eql?('rorganize')
          title = title_home_controller
        else
          title = title_tag_specific_pages(title)
          title = title_tag_project_name(title)
        end
        title
      end

      def title_home_controller
        if action_name.eql?('view_profile')
          "#{params[:user]} (#{title_capitalize_text(params[:user].split('-'))})"
        else
          'RORganize'.freeze
        end
      end

      def title_tag_project_name(title)
        if @project && !@project.new_record?
          title += " · #{@project.slug.capitalize}"
        elsif controller_name.eql?('profiles')
          if action_name.eql?('view_profile')
            title += User.current.login + " (#{User.current.caption})"
          else
            title += "#{t(:text_your_profile)} #{title_tag_profile_action(title)}"
          end
        else
          title += ' · RORganize'.freeze
        end
        title
      end

      def title_tag_specific_pages(title)
        unless controller_name.eql?('profiles')
          title += title_tag_action(title)
        end
        title
      end

      def title_tag_profile_action(title)
        title += '· '
        case action_name
          when 'change_password'
            title += t(:link_change_password)
          when 'change_email'
            title += t(:link_change_email)
          when 'notification_preferences'
            title += t(:link_notification_preferences)
          when 'projects'
            title += t(:text_your_projects)
          when 'custom_queries'
            title += t(:text_your_queries)
          when 'spent_time'
            title += t(:text_your_spent_time)
          else
            ''
        end
      end

      def title_tag_action(title)
        case action_name
          when 'activity'
            title += t(:label_activity)
          when 'overview'
            title += t(:label_overview)
          when 'show'
            title += title_tag_show_action(title)
          when 'edit'
            title += title_tag_edit_action(title)
          when 'new'
            title += title_tag_new_action(title)
          else
            title += humanize_controller_name
        end
      end

      def title_tag_show_action(title)
        title += singular_controller_name
        if params[:id]
          title += " · ##{params[:id]}"
        end
        title
      end

      def title_tag_edit_action(title)
        title += 'Edit '
        title += singular_controller_name
        if params[:id]
          title += " · ##{params[:id]}"
        end
        title
      end

      def title_tag_new_action(title)
        title += 'New '
        title += singular_controller_name
      end

      def singular_controller_name
        humanize_controller_name.singularize
      end

      def humanize_controller_name
        title_capitalize_text(controller_name.split('_'))
      end

      def title_capitalize_text(array)
        array.collect { |chunk| chunk.capitalize }.join(' ')
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