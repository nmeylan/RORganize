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
      build_menu_version
      build_menu_category
    end
    add_extra_action_edit('Documents',  h.edit_document_path(@project.slug, @collection_ids[0]))
    add_extra_action_delete('Documents')
  end

  def build_menu_category
    @menu[:categories].caption = h.t(:field_category)
    @menu[:categories].glyph_name = Rorganize::ACTION_ICON[:category_id]
    @menu[:categories].all = @project.categories.collect { |category| category }
    @menu[:categories].currents = @collection.collect { |document| document.category }.uniq
    @menu[:categories].attribute_name = 'category_id'
    @menu[:categories].none_allowed = true
  end

  def build_menu_version
    @menu[:versions].caption = h.t(:field_version)
    @menu[:versions].glyph_name = Rorganize::ACTION_ICON[:version_id]
    @menu[:versions].all = @project.versions.collect { |version| version }
    @menu[:versions].currents = @collection.collect { |document| document.version }.uniq
    @menu[:versions].attribute_name = 'version_id'
    @menu[:versions].none_allowed = true
  end
end