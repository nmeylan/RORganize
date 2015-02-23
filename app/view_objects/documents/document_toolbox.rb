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
      build_menu_category
      build_menu_version
    end
    add_extra_action_edit('Documents',  h.edit_document_path(@project.slug, @collection_ids[0]))
    add_extra_action_delete('Documents')
  end

  def build_menu_version
    generic_toolbox_menu_builder(h.t(:field_version), :versions, :version_id, @project.active_versions, Proc.new(&:version), true)
  end

  def build_menu_category
    generic_toolbox_menu_builder(h.t(:field_category), :categories, :category_id, @project.categories, Proc.new(&:category), true)
  end
end