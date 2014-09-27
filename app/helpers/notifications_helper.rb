# Author: Nicolas Meylan
# Date: 20.09.14
# Encoding: UTF-8
# File: notifications_helper.rb

module NotificationsHelper
  # Render a list of notifications.
  # @param [Array] collection of notifications.
  def list(collection)
    hash = {}
    collection.each { |element| hash[element.project.slug] ||= []; hash[element.project.slug] << element }
    hash.collect do |project_slug, notifications|
      notifications_block(project_slug, notifications)
    end.join.html_safe
  end

  # Render a block of notifications.
  # @param [String] project_slug : slug of project that belongs to notifications.
  # @param [Array] notifications : array of Notification.
  def notifications_block(project_slug, notifications)
    content_tag :div, class: 'box' do
      safe_concat box_header_tag((link_to medium_glyph(project_slug, 'repo'), project_path(project_slug)), 'header header_left', &Proc.new {
        link_to t(:link_mark_all_as_read), destroy_all_for_project_notifications_path(project_slug), {method: :delete, 'data-confirm' => t(:confirm_mark_all_as_read), class: 'button'}
      })
      safe_concat content_tag :ul, class: 'fancy_list fancy_list_mini', &Proc.new {
        notifications.collect do |notification|
          content_tag :li, class: 'fancy_list_item' do
            safe_concat notification.link_to_notifiable
            safe_concat content_tag :span, {class: 'right_content_list'}, &Proc.new {
              safe_concat notification.notification_info
              safe_concat notification.from.user_link
              safe_concat notification.recipient_type
            }
          end
        end.join.html_safe
      }
    end
  end

  # Render a sidebar for notifications.
  def sidebar(projects)

  end
end