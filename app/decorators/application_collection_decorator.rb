# Author: Nicolas Meylan
# Date: 25.06.14
# Encoding: UTF-8
# File: application_collection_decorator.rb

class ApplicationCollectionDecorator < Draper::CollectionDecorator
  include ActionView::Helpers::UrlHelper
  include ActionDispatch::Routing
  include Rails.application.routes.url_helpers
  include Rorganize::PermissionManager::PermissionHandler

  # @return [String] path to the default pagination action.
  def pagination_path
    h.url_for({controller: h.controller_name, action: 'index'})
  end

  # Generic collection render. Give a block for the render.
  # @param [Boolean] no_pagination : if false don't display pagination when there are too many results, else display pagination.
  # @param [String] no_data_text : text to display when there is no data to display.
  def display_collection(no_pagination = false, no_data_text = nil, no_scroll = false)
    h.content_tag :div, {id: "#{h.controller_name}_content"} do
      if object.to_a.any?
        h.safe_concat h.content_tag :div, {class: "#{no_scroll ? '' : 'autoscroll'}"}, &Proc.new {
          if block_given?
            h.safe_concat yield
          else
            h.safe_concat h.list(self)
          end
        }
        h.safe_concat(h.paginate(object, h.session[h.controller_name.to_sym], pagination_path)) unless no_pagination || (object.to_a.size < 25 && h.session[h.controller_name.to_sym][:current_page].to_i < 2)
      else
        h.no_data(no_data_text)
      end
    end
  end

  # Generic new link.
  # @param [String] label : link label.
  # @param [String] path to controller.
  # @param [Project] project the project that belongs to the model.
  # @param [Hash] options : html_options.
  def new_link(label, path, project = nil, options = {})
    link_to_with_permissions(h.glyph(label, 'plus'), path, project, nil, options)
  end
end