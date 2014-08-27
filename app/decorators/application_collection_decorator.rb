# Author: Nicolas Meylan
# Date: 25.06.14
# Encoding: UTF-8
# File: application_collection_decorator.rb

class ApplicationCollectionDecorator < Draper::CollectionDecorator
  include ActionView::Helpers::UrlHelper
  include ActionDispatch::Routing
  include Rails.application.routes.url_helpers
  include Rorganize::PermissionManager::PermissionHandler

  def pagination_path
    h.url_for({controller: h.controller_name, action: 'index'})
  end

  def display_collection(no_pagination = false)
    h.content_tag :div, id: "#{h.controller_name}_content" do
      if object.to_a.any?
        if block_given?
          h.safe_concat yield
        else
          h.safe_concat h.list(self)
        end
        h.safe_concat(h.paginate(object, h.session[h.controller_name.to_sym], pagination_path)) unless no_pagination || (object.to_a.size < 25 && h.session[h.controller_name.to_sym][:current_page].to_i < 2)
      else
        h.no_data
      end
    end
  end

  def new_link(label, path, project = nil, options = {})
    link_to_with_permissions(h.glyph(label, 'plus'), path, project, nil, options)
  end
end