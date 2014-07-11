# Author: Nicolas Meylan
# Date: 11.07.14
# Encoding: UTF-8
# File: trackers_helper.rb

module TrackersHelper
  def list(collection)
    content_tag :table, class: 'tracker list' do
      safe_concat content_tag :tr, class: 'header', &Proc.new {
        safe_concat content_tag :td, t(:field_name)
        safe_concat content_tag :td, nil
      }
      safe_concat(collection.collect do |tracker|
        content_tag :tr, {class: 'odd_even', id: %Q(tracker-#{tracker.id})} do
          safe_concat content_tag :td, tracker.edit_link, class: 'name'
          safe_concat content_tag :td, tracker.delete_link, class: 'action'
        end
      end.join.html_safe)
    end
  end
end