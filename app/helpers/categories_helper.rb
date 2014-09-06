# Author: Nicolas Meylan
# Date: 5 mars 2013
# Encoding: UTF-8
# File: categories_helper.rb

module CategoriesHelper

  # Build a list of categories.
  # @param [Array] collection of categories.
  def list(collection)
    content_tag :table, class: 'category list' do
      safe_concat content_tag :tr, class: 'header', &Proc.new {
        safe_concat content_tag :td, sortable('categories.name', t(:field_name))
        safe_concat content_tag :td, nil
      }
      safe_concat(collection.collect do |category|
        content_tag :tr, {class: 'odd_even', id: %Q(category-#{category.id})} do
          safe_concat content_tag :td, category.edit_link, class: 'name'
          safe_concat content_tag :td, category.delete_link, class: 'action'
        end
      end.join.html_safe)
    end
  end
end
