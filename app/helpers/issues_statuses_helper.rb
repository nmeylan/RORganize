# Author: Nicolas Meylan
# Date: 04.07.14
# Encoding: UTF-8
# File: issues_statuses_helper.rb

module IssuesStatusesHelper

  # Build a list of issues_statuses.
  # @param [Array] collection of issues_statuses.
  def list(collection)
    content_tag :table, {class: 'issues-status list'}, &Proc.new {
      safe_concat content_tag :tr, class: 'header', &Proc.new {
        safe_concat content_tag :th, 'Name', class: 'list-left'
        safe_concat content_tag :th, 'Default done ratio'
        safe_concat content_tag :th, 'Is closed?'
        safe_concat content_tag :th, nil
        safe_concat content_tag :th, nil
      }
      safe_concat(collection.sort { |x, y| x.enumeration.position <=> y.enumeration.position }.collect do |status|
        content_tag :tr, {class: 'odd-even', id: status.id} do
          safe_concat content_tag :td, status.edit_link, {class: 'list-left name'}
          safe_concat content_tag :td, status.default_done_ratio, {class: 'list-center done-ratio'}
          safe_concat content_tag :td, status.is_closed?, {class: 'list-center is-closed'}
          safe_concat list_sort_actions(collection, status)
          safe_concat content_tag :td, status.delete_link, {class: 'action'}
        end
      end.join.html_safe)
    }
  end
end