# Author: Nicolas Meylan
# Date: 06.07.14
# Encoding: UTF-8
# File: queries_helper.rb

module QueriesHelper
  # Build a list of queries.
  # @param [Array] collection of queries.
  def query_list(collection)
    content_tag :table, class: 'query list' do
      concat query_list_header(collection)
      concat(query_list_body(collection))
    end
  end

  def query_list_body(collection)
    collection.collect do |query|
      query_list_row(query)
    end.join.html_safe
  end

  def query_list_row(query)
    content_tag :tr, {class: 'odd-even query-tr', id: "#{query.id}"} do
      list_td query.object_type, class: 'list-left object-type'
      list_td query.show_link, class: 'list-left name'
      list_td query.author, class: 'list-left author'
      list_td nil, {class: 'action list-right'}, &Proc.new {
        concat query.edit_link
        concat query.delete_link
      }
    end
  end

  def query_list_header(collection)
    content_tag :tr, class: 'header' do
      list_th sortable('queries.object_type', 'type', collection.sortable_action), class: 'list-left'
      list_th sortable('queries.name', t(:field_name), collection.sortable_action), class: 'list-left'
      list_th sortable('users.name', t(:label_author), collection.sortable_action), class: 'list-left'
      list_th nil
    end
  end
end