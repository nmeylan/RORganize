# Author: Nicolas Meylan
# Date: 6 avr. 2013
# Encoding: UTF-8
# File: documents_helper.rb
require 'documents/document_filter'
require 'documents/document_toolbox'
module DocumentsHelper
  include CommentsHelper
  include DocumentsHelpers::DocumentsFilterHelper

  def list(collection)
    generic_list(collection, {class: 'document list', 'data-link' => toolbox_project_documents_path(@project.slug)})
  end

  def list_header
    content_tag :thead do
      content_tag :tr, class: 'header' do
        list_th link_to(glyph('', 'check'), '#', {class: 'icon-checked', id: 'check-all', 'cb_checked' => 'b'})
        list_th sortable('documents.sequence_id', '#')
        list_th sortable('documents.name', Document.human_attribute_name(:name)), {class: 'list-left no-padding-left'}
        list_th sortable('categories.name', Document.human_attribute_name(:category_id))
        list_th sortable('versions.name', Document.human_attribute_name(:version_id))
        list_th nil, {class: 'optional-cell'}
        list_th nil, {class: 'optional-cell'}
      end
    end
  end

  def list_row(document)
    disabled_class = !document.user_allowed_to_edit? ? 'disabled-toolbox' : ''
    content_tag :tr, class: "odd-even document-tr has-context-menu #{disabled_class}" do
      list_td check_box_tag("document-#{document.sequence_id.to_s}", document.sequence_id, false, disabled: !document.user_allowed_to_edit?), {class: 'cell-checkbox'}
      list_td document.sequence_id, class: 'list-center id'
      list_td link_to(document.resized_caption(100), project_document_path(@project.slug, document)), {class: 'name', id: document.sequence_id}
      list_td document.display_category, class: 'list-center category'
      list_td document.display_version, class: 'list-center version'
      list_td document.comment_presence_indicator, class: 'icon-information'
      list_td document.attachment_presence_indicator, class: 'icon-information'
    end
  end


  # Build a toolbox render for document toolbox
  # @param [Array] collection : a collection of selected Documents that will be bulk edited.
  def toolbox(collection)
    toolbox_tag(DocumentToolbox.new(collection, @project, User.current))
  end
end
