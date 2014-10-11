# Author: Nicolas Meylan
# Date: 20.09.14
# Encoding: UTF-8
# File: notifications_helper.rb

module NotificationsHelper
  # Render a list of notifications.
  # @param [Array] collection of notifications.
  def list(collection)
    hash = collection.inject(Hash.new { |h, k| h[k] = [] }) { |memo, element| memo[element.project.slug] << element; memo }
    hash.collect do |project_slug, notifications|
      notifications_block(project_slug, notifications)
    end.join.html_safe
  end

  # Render a block of notifications.
  # @param [String] project_slug : slug of project that belongs to notifications.
  # @param [Array] notifications : array of Notification.
  def notifications_block(project_slug, notifications)
    content_tag :div, class: 'box notification-list' do
      safe_concat notification_block_header(project_slug)
      safe_concat notification_block_content(notifications)
    end
  end

  def notification_block_content(notifications)
    content_tag :ul, class: 'fancy-list fancy-list-mini' do
      notifications.collect do |notification|
        notification_block_row(notification)
      end.join.html_safe
    end
  end

  def notification_block_row(notification)
    content_tag :li, class: 'fancy-list-item' do
      safe_concat notification.link_to_notifiable
      safe_concat notification_block_row_right_content(notification)
    end
  end

  def notification_block_row_right_content(notification)
    content_tag :span, {class: 'right-content-list'} do
      safe_concat notification.notification_info
      safe_concat notification.from.user_link
      safe_concat notification.recipient_type
    end
  end

  def notification_block_header(project_slug)
    box_header_tag link_to(medium_glyph(project_slug, 'repo'), project_path(project_slug)), 'header header_left' do
      link_to t(:link_mark_all_as_read), destroy_all_for_project_notifications_path(project_slug),
              {method: :delete, 'data-confirm' => t(:confirm_mark_all_as_read), class: 'button'}
    end
  end

  # Render a sidebar for notifications.
  def sidebar(filters, projects)
    labels_hash = {all: t(:label_all), participants: t(:label_participating), watchers: t(:label_watching)}
    glyphs_hash = {all: 'inbox', participants: 'person', watchers: 'eye'}
    content_tag :div, class: 'left-sidebar' do
      safe_concat notification_recipient_type_sidebar(filters, glyphs_hash, labels_hash)
      safe_concat content_tag :hr
      safe_concat notification_projects_sidebar(projects)
    end
  end

  def notification_projects_sidebar(projects)
    content_tag :ul, {class: 'filter-sidebar small'} do
      projects.keys.collect do |project|
        projects_sidebar_row(project, projects)
      end.join.html_safe
    end
  end

  def projects_sidebar_row(project, projects)
    content_tag :li do
      selected = projects[project][:id].to_s.eql?(@sessions[:filter_project]) ? 'selected' : ''
      link_to notifications_path(filter: @sessions[:filter_recipient_type],
                                 project: projects[project][:id]),
              {class: "filter-item #{selected}"} do
        safe_concat sidebar_count_tag(projects[project][:count])
        safe_concat glyph(project, 'repo')
      end
    end
  end

  def notification_recipient_type_sidebar(filters, glyphs_hash, labels_hash)
    content_tag :ul, {class: 'filter-sidebar'} do
      filters.keys.collect do |filter|
        recipient_type_sidebar_row(filter, filters, glyphs_hash, labels_hash)
      end.join.html_safe
    end
  end

  def recipient_type_sidebar_row(filter, filters, glyphs_hash, labels_hash)
    content_tag :li do
      selected = filter.to_s.eql?(@sessions[:filter_recipient_type]) ? 'selected' : ''
      link_to notifications_path(filter: filter),
              {class: "filter-item #{selected}"} do
        safe_concat sidebar_count_tag(filters[filter])
        safe_concat glyph(labels_hash[filter], glyphs_hash[filter])
      end

    end
  end
end