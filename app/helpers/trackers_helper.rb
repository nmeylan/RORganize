# Author: Nicolas Meylan
# Date: 11.07.14
# Encoding: UTF-8
# File: trackers_helper.rb

module TrackersHelper
  # Build a list of trackers.
  # @param [Array] collection of trackers.
  def list(collection)
    collection_one_column_renderer(collection, 'tracker', 'trackers.name')
  end



  # @param [Array] collection : array of trackers.
  # @param [Array] checked_ids : array of trackers id used by project.
  def project_tracker_list(collection, checked_ids)
    safe_concat content_tag :label, t(:link_trackers)
    collection.collect do |tracker|
      safe_concat label_tag "[trackers][#{tracker.name}]", tracker.caption, {class: 'normal-label'}
      safe_concat check_box_tag "[trackers][#{tracker.name}]", tracker.id, checked_ids.include?(tracker.id)
    end.join.html_safe
  end
end