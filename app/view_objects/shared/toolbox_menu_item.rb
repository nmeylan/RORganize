# Author: Nicolas Meylan
# Date: 01.07.14
# Encoding: UTF-8
# File: toolbox_menu.rb

class ToolboxMenuItem
  attr_accessor :name, :attribute_name, :all, :currents, :context, :caption, :glyph_name, :none_allowed

  def initialize(name)
    @name = name
    @attribute_name = name
    @caption = name
    @glyph_name = 'puzzle'
    @none_allowed = false #does attribute can be set to nil? (e.g Issue : assigned_to can be nil)
    @all = []
    @currents = []
    @context = {}
  end
end