# Author: Nicolas Meylan
# Date: 30.06.14
# Encoding: UTF-8
# File: toolbox.rb
require 'shared/toolbox_menu_item'
class Toolbox
  attr_accessor :collection, :collection_ids, :menu, :path, :extra_actions
  # @param [Array] collection : selected items for the bulk edition.
  # @param [User] user
  # @param [Hash] context : excepted key-value  are {path: 'the "action" attribute of the form'}
  def initialize(collection, user, context = {})
    @collection = collection
    @collection_ids = collection.collect { |element| element.id }
    @path = context[:path]
    @user = user
    @menu = Hash.new { |h, k| h[k] = ToolboxMenuItem.new(k) }
    @extra_actions = []
  end

  # @param [String] controller_name.
  def add_extra_action_delete(controller_name)
    if @user.allowed_to?('destroy', controller_name, @project)
      @extra_actions << h.link_to(h.glyph(h.t(:link_delete), 'trashcan'), '#', {class: 'icon icon-del', id: 'open-delete-overlay'})
    end
  end

  # @param [String] controller_name.
  def add_extra_action_edit(controller_name, path)
    if @user.allowed_to?('edit', controller_name, @project)
      @extra_actions << h.link_to(h.glyph(h.t(:link_edit), 'pencil'), path) if @collection.size == 1
    end
  end
end