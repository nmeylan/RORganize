# Author: Nicolas Meylan
# Date: 25.06.14
# Encoding: UTF-8
# File: application_collection_decorator.rb

class ApplicationCollectionDecorator < Draper::CollectionDecorator
  include Rorganize::PermissionManager::PermissionHandler

  def display_collection
    if object.any?
      if block_given?
        yield
      else
        h.list(self)
      end
    else
     h.content_tag :div, h.t(:text_no_data), class: 'no-data'
    end
  end

  def new_link(label, path, project = nil)
    link_to_with_permissions(h.glyph(label, 'plus'), path ,project, nil)
  end
end