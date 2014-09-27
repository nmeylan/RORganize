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
end