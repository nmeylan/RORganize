# Author: Nicolas Meylan
# Date: 25.06.14
# Encoding: UTF-8
# File: categories_decorator.rb

class CategoriesDecorator < ApplicationCollectionDecorator

  def no_data_glyph_name
    'tag'
  end

  def display_collection
    super(false, h.t(:text_no_categories))
  end

  # see #ApplicationCollectionDecorator::new_link
  def new_link
    super(h.t(:link_new_category), h.new_category_path(context[:project].slug), context[:project])
  end

end