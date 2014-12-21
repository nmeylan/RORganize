# Author: Nicolas Meylan
# Date: 04.07.14
# Encoding: UTF-8
# File: issues_statuses_helper.rb

module IssuesStatusesHelper

  # Build a list of issues_statuses.
  # @param [Array] collection of issues_statuses.
  def list(collection)
    content_tag :table, {class: 'issues-status list'} do
      concat list_header
      concat list_body(collection)
    end
  end

  def list_body(collection)
    collection.sort { |x, y| x.enumeration.position <=> y.enumeration.position }.collect do |status|
      list_row(collection, status)
    end.join.html_safe
  end

  def list_row(collection, status)
    content_tag :tr, {class: 'odd-even', id: status.id} do
      list_td status.edit_link, {class: 'list-left name'}
      list_td status.default_done_ratio, {class: 'list-center done-ratio'}
      list_td status.is_closed?, {class: 'list-center is-closed'}
      concat list_sort_actions(collection, status)
      list_td status.delete_link, {class: 'action'}
    end
  end

  def list_header
    content_tag :tr, class: 'header' do
      list_th 'Name', class: 'list-left'
      list_th 'Default done ratio'
      list_th 'Is closed?'
      list_th nil
      list_th nil
    end
  end
end