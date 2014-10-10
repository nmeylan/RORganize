# Author: Nicolas Meylan
# Date: 6 avr. 2013
# Encoding: UTF-8
# File: documents_helper.rb
require 'documents/document_filter'
require 'documents/document_toolbox'
module DocumentsHelper
  include CommentsHelper

  # Build a list of documents.
  # @param [Array] collection of documents.
  def list(collection)
    content_tag :table, {class: 'document list', 'data-link' => toolbox_documents_path(@project.slug)}, &Proc.new {
      safe_concat content_tag :tr, class: 'header', &Proc.new {
        safe_concat content_tag :th, link_to(glyph('', 'check'), '#', {class: 'icon-checked', id: 'check-all', 'cb_checked' => 'b'})
        safe_concat content_tag :th, sortable('documents.id', '#')
        safe_concat content_tag :th, sortable('documents.name', 'Name'), {class: 'list-left no-padding-left'}
        safe_concat content_tag :th, sortable('categories.name', 'Category')
        safe_concat content_tag :th, sortable('versions.name', 'Target phase')
        safe_concat content_tag :th, nil, {class: 'optional-cell'}
        safe_concat content_tag :th, nil, {class: 'optional-cell'}
      }
      safe_concat(collection.collect do |document|
        content_tag :tr, class: 'odd-even document-tr has-context-menu' do
          safe_concat content_tag :td, check_box_tag("document-#{document.id.to_s}", document.id), {class: 'cell-checkbox'}
          safe_concat content_tag :td, document.id, class: 'list-center id'
          safe_concat content_tag :td, link_to(document.resized_caption(100), document_path(@project.slug, document.id)), {class: 'name', id: document.id}
          safe_concat content_tag :td, document.display_category, class: 'list-center category'
          safe_concat content_tag :td, document.display_version, class: 'list-center version'
          safe_concat content_tag :td, document.comment_presence_indicator, class: 'icon-information'
          safe_concat content_tag :td, document.attachment_presence_indicator, class: 'icon-information'
        end
      end.join.html_safe)
    }
  end

  # Build a json filter form.
  def documents_generics_form_to_json
    form_hash = {}
    filter_content_hash = DocumentFilter.new(@project).content
    hash_for_radio = filter_content_hash['hash_for_radio']
    hash_for_select = filter_content_hash['hash_for_select']
    form_hash['category'] = generic_filter(:simple_select, 'Category', 'category', hash_for_radio['category'], hash_for_select['category'])
    form_hash['created_at'] = generic_filter(:date, 'Created at', 'created_at', hash_for_radio['created'])
    form_hash['name'] = generic_filter(:text, 'Name', 'name', hash_for_radio['name'])
    form_hash['version'] = generic_filter(:simple_select, 'Version', 'version', hash_for_radio['version'], hash_for_select['version'])
    form_hash['updated_at'] = generic_filter(:date, 'Updated', 'updated_at', hash_for_radio['updated'])
    form_hash.each { |_, v| v.tr('"', "'").gsub(/\n/, '') }
    form_hash.to_json
  end

  # Build a toolbox render for document toolbox
  # @param [DocumentToolbox] documents_toolbox
  def document_toolbox(documents_toolbox)
    toolbox_tag(DocumentToolbox.new(documents_toolbox, @project, User.current))
  end
end
