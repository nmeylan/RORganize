# Author: Nicolas Meylan
# Date: 25.06.14
# Encoding: UTF-8
# File: application_collection_decorator.rb

class ApplicationCollectionDecorator < Draper::CollectionDecorator
  include ActionView::Helpers::UrlHelper
  include ActionDispatch::Routing
  include Rails.application.routes.url_helpers
  include Rorganize::Managers::PermissionManager::PermissionHandler
  include GenericDecorator

  # @return [String] path to the default pagination action.
  def pagination_path
    h.url_for({controller: h.controller_name, action: 'index'})
  end

  # Generic collection render. Give a block for the render.
  # @param [Boolean] no_pagination : if false don't display pagination when there are too many results, else display pagination.
  # @param [String] no_data_text : text to display when there is no data to display.
  def display_collection(no_pagination = false, no_data_text = nil, no_scroll = false)
    h.content_tag :div, {id: "#{h.controller_name.tr('_', '-')}-content"} do
      if object.to_a.any?
        proc = Proc.new if block_given?
        render_list(no_pagination, no_scroll, proc)
      else
        h.no_data(no_data_text, no_data_glyph_name, true)
      end
    end
  end

  def render_list(no_pagination, no_scroll, proc = nil)
    collection_content(no_scroll, proc)
    collection_pagination(no_pagination)
  end

  def collection_content(no_scroll, proc = nil)
    h.concat h.content_tag :div, {class: "#{no_scroll ? '' : 'autoscroll'}"}, &Proc.new {
      if proc
        proc.call
      else
        h.concat h.list(self)
      end
    }
  end

  def collection_pagination(no_pagination)
    unless no_pagination?(no_pagination)
      h.concat(h.paginate(object, h.session[h.controller_name.to_sym], pagination_path))
    end
  end

  def no_pagination?(no_pagination)
    no_pagination || (object.to_a.size < 25 && h.session[h.controller_name.to_sym][:current_page].to_i < 2)
  end

  def no_data_glyph_name
    ''
  end

  def display_total_entries
    h.content_tag :span, object.total_entries, {class: 'counter total-entries'}
  end

  def collection_contextual_title(title)
    h.content_tag :span do
      h.concat "#{title} "
      h.concat display_total_entries
    end
  end

end