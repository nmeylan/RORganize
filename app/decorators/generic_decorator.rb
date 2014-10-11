# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: generic_decorator.rb

module GenericDecorator
# Generic new link.
# @param [String] label : link label.
# @param [String] path to controller.
# @param [Project] project the project that belongs to the model.
# @param [Hash] options : html_options.
  def new_link(label, path, project = nil, options = {})
    options = options.merge({class: 'button new'})
    link_to_with_permissions(h.glyph(label, 'plus'), path, project, nil, options)
  end
end