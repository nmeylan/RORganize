# Author: Nicolas Meylan
# Date: 06.07.14
# Encoding: UTF-8
# File: queries_helper.rb

module QueriesHelper
  def query_list(collection)
    content_tag :table, class: 'query list' do
      safe_concat content_tag :tr, class: 'header', &Proc.new {
        safe_concat content_tag :td, sortable('queries.name', t(:field_name), collection.sortable_action)
        safe_concat content_tag :td, sortable('users.name', t(:label_author), collection.sortable_action)
        safe_concat content_tag :td, nil
        safe_concat content_tag :td, nil
      }
      safe_concat(collection.collect do |query|
        content_tag :tr, {class: 'odd_even query_tr', id: "#{query.id}"} do
          safe_concat content_tag :td, query.show_link, class: 'list_left name'
          safe_concat content_tag :td, query.author, class: 'list_left author'
          safe_concat content_tag :td, query.edit_link, class: 'action'
          safe_concat content_tag :td, query.delete_link, class: 'action'
        end
      end.join.html_safe)
    end
  end
end