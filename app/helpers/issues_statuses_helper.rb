# Author: Nicolas Meylan
# Date: 04.07.14
# Encoding: UTF-8
# File: issues_statuses_helper.rb

module IssuesStatusesHelper
  def list(collection)
    content_tag :table, {class: 'issues_status list'}, &Proc.new {
      safe_concat content_tag :tr, class: 'header', &Proc.new {
        safe_concat content_tag :th, 'Name', class: 'list_left'
        safe_concat content_tag :th, 'Default done ratio'
        safe_concat content_tag :th, 'Is closed?'
        safe_concat content_tag :th, nil
        safe_concat content_tag :th, nil
      }
      safe_concat(collection.sort{|x,y| x.enumeration.position <=> y.enumeration.position}.collect do |status|
        content_tag :tr, {class: 'odd_even', id: status.id} do
          safe_concat content_tag :td, status.edit_link, {class: 'list_left name'}
          safe_concat content_tag :td, status.default_done_ratio, {class: 'list_center done_ratio'}
          safe_concat content_tag :td, status.is_closed?, {class: 'list_center is_closed'}
          safe_concat content_tag :td, {class: 'action'}, &Proc.new{
            safe_concat status.inc_position_link
            safe_concat status.dec_position_link(collection.size)
          }
          safe_concat content_tag :td, status.delete_link,{class: 'action'}
        end
      end.join.html_safe)
    }
  end
end