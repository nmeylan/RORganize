# Author: Nicolas Meylan
# Date: 11.07.14
# Encoding: UTF-8
# File: trackers_helper.rb

module TrackersHelper

  def list(collection)
    content_tag :table, {class: 'tracker list'} do
      concat list_header
      concat list_body(collection)
    end
  end

  def list_body(collection)
    collection.sort_by(&:position).collect do |tracker|
      list_row(collection, tracker)
    end.join.html_safe
  end

  def list_row(collection, tracker)
    content_tag :tr, {class: 'odd-even', id: tracker.id} do
      list_td tracker.edit_link, {class: 'list-left name'}
      concat list_sort_actions(collection, tracker)
      list_td tracker.delete_link, {class: 'delete-action action'}
    end
  end

  def list_header
    content_tag :tr, class: 'header' do
      list_th 'Name', class: 'list-left'
      list_th nil
      list_th nil
    end
  end


  # @param [Array] collection : array of trackers.
  # @param [Array] checked_ids : array of trackers id used by project.
  def project_tracker_list(collection, checked_ids)
    concat content_tag :label, t(:link_trackers)
    collection.collect do |tracker|
      concat label_tag "[trackers][#{tracker.name}]", tracker.caption, {class: 'normal-label'}
      concat check_box_tag "[trackers][#{tracker.name}]", tracker.id, checked_ids.include?(tracker.id)
    end.join.html_safe
  end
end