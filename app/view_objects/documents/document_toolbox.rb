# Author: Nicolas Meylan
# Date: 26.06.14
# Encoding: UTF-8
# File: document_toolbox.rb
require 'shared/toolbox'

class DocumentToolbox < Toolbox
  include Draper::ViewHelpers

  def initialize(collection, project, user)
    super(collection, user, {path: h.toolbox_documents_path(project.slug)})
    @project = project
    build_menu
  end

  def build_menu
    #Menu item names
    if @user.allowed_to?('edit', 'Documents', @project)
      @menu[:versions].caption = h.t(:field_version)
      @menu[:categories].caption = h.t(:field_category)
      #Menu item glyphs
      @menu[:versions].glyph_name = Rorganize::ACTION_ICON[:version_id]
      @menu[:categories].glyph_name = Rorganize::ACTION_ICON[:category_id]
      #Menu item content
      @menu[:versions].all = @project.versions.collect { |version| version }
      @menu[:categories].all = @project.categories.collect { |category| category }
      #documents current states for each fields
      @menu[:versions].currents = @collection.collect { |document| document.version }.uniq
      @menu[:categories].currents = @collection.collect { |document| document.category }.uniq
      #Attribute name
      @menu[:versions].attribute_name = 'version_id'
      @menu[:categories].attribute_name = 'category_id'
      @extra_actions << h.link_to(h.glyph(h.t(:link_edit), 'pencil'), h.edit_document_path(@project.slug, @collection_ids[0])) if @collection.size == 1
    end
    if @user.allowed_to?('destroy','Documents',@project)
      @extra_actions << h.link_to(h.glyph(h.t(:link_delete),'trashcan'), '#', {:class => 'icon icon-del', :id=> 'open_delete_overlay'})
    end
  end
end