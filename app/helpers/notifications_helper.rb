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
    content_tag :div, class: 'box notification_list' do
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
  def sidebar(filters, projects)
    labels_hash = {all: t(:label_all), participants: t(:label_participating), watchers: t(:label_watching)}
    glyphs_hash = {all: 'inbox', participants: 'person', watchers: 'eye'}
    content_tag :div, class: 'left_sidebar' do
      safe_concat content_tag :ul, {class: 'filter_sidebar'}, &Proc.new {
        filters.keys.collect do |filter|
          content_tag :li do
            link_to notifications_path(filter: filter),
                    {class: "filter_item #{filter.to_s.eql?(@sessions[:filter_recipient_type]) ? 'selected' : ''}"} do
              safe_concat sidebar_count_tag(filters[filter])
              safe_concat glyph(labels_hash[filter], glyphs_hash[filter])
            end

          end
        end.join.html_safe
      }
      safe_concat content_tag :hr
      safe_concat content_tag :ul, {class: 'filter_sidebar small'}, &Proc.new {
        projects.keys.collect do |project|
          content_tag :li do
            link_to notifications_path(filter: @sessions[:filter_recipient_type], project: projects[project][:id]),
                    {class: "filter_item #{projects[project][:id].to_s.eql?(@sessions[:filter_project]) ? 'selected' : ''}"} do
              safe_concat sidebar_count_tag(projects[project][:count])
              safe_concat glyph(project, 'repo')
            end

          end
        end.join.html_safe
      }
    end
  end
end