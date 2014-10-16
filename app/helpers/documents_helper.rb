# Author: Nicolas Meylan
# Date: 6 avr. 2013
# Encoding: UTF-8
# File: documents_helper.rb
require 'documents/document_filter'
require 'documents/document_toolbox'
module DocumentsHelper
  include CommentsHelper
  include Rorganize::Helpers::DocumentsHelper

  def list(collection)
    generic_list(collection, {class: 'document list', 'data-link' => toolbox_documents_path(@project.slug)})
  end

  def list_header
    content_tag :thead do
      content_tag :tr, class: 'header' do
        list_th link_to(glyph('', 'check'), '#', {class: 'icon-checked', id: 'check-all', 'cb_checked' => 'b'})
        list_th sortable('documents.id', '#')
        list_th sortable('documents.name', 'Name'), {class: 'list-left no-padding-left'}
        list_th sortable('categories.name', 'Category')
        list_th sortable('versions.name', 'Target phase')
        list_th nil, {class: 'optional-cell'}
        list_th nil, {class: 'optional-cell'}
      end
    end
  end

  def list_row(document)
    content_tag :tr, class: 'odd-even document-tr has-context-menu' do
      list_td check_box_tag("document-#{document.id.to_s}", document.id), {class: 'cell-checkbox'}
      list_td document.id, class: 'list-center id'
      list_td link_to(document.resized_caption(100), document_path(@project.slug, document.id)), {class: 'name', id: document.id}
      list_td document.display_category, class: 'list-center category'
      list_td document.display_version, class: 'list-center version'
      list_td document.comment_presence_indicator, class: 'icon-information'
      list_td document.attachment_presence_indicator, class: 'icon-information'
    end
  end


  # Build a toolbox render for document toolbox
  # @param [DocumentToolbox] documents_toolbox
  def document_toolbox(documents_toolbox)
    toolbox_tag(DocumentToolbox.new(documents_toolbox, @project, User.current))
  end
end
