# Author: Nicolas Meylan
# Date: 5 mars 2013
# Encoding: UTF-8
# File: categories_helper.rb

module CategoriesHelper

  # Build a list of categories.
  # @param [Array] collection of categories.
  def list(collection)
    collection_one_column_renderer(collection, 'category', 'categories.name')
  end
end
