# Author: Nicolas Meylan
# Date: 6 avr. 2013
# Encoding: UTF-8
# File: documents_helper.rb
require 'documents/document_filter'
require 'documents/document_toolbox'
module DocumentsHelper

  def list(collection)
    safe_concat content_tag :table, {class: 'document list', 'data-link' => toolbox_documents_path(@project.slug)}, &Proc.new {
      safe_concat content_tag :tr, class: 'header', &Proc.new {
        safe_concat content_tag :th, link_to(glyph('', 'check'), '#', {:class => 'icon-checked', :id => 'check_all', 'cb_checked' => 'b'})
        safe_concat content_tag :th, sortable('documents.id', '#')
        safe_concat content_tag :th, sortable('documents.name', 'Name')
        safe_concat content_tag :th, sortable('categories.name', 'Category')
        safe_concat content_tag :th, sortable('versions.name', 'Target phase')
      }
      safe_concat(collection.collect do |document|
        content_tag :tr, class: 'odd_even document_tr' do
          safe_concat content_tag :td, check_box_tag("document-#{document.id.to_s}", document.id)
          safe_concat content_tag :td, document.id, class: 'list_center id'
          safe_concat content_tag :td, link_to(document.caption, document_path(@project.slug, document.id)), {class: 'name', id: document.id}
          safe_concat content_tag :td, document.category, class: 'list_center category'
          safe_concat content_tag :td, document.version, class: 'list_center version'
        end
      end.join.html_safe)
    }
    paginate(collection, session[:controller_documents_per_page], documents_path(@project.slug))
  end

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
    form_hash.each { |_, v| v.gsub(/"/, "'").gsub(/\n/, '') }
    form_hash.to_json
  end

  def document_toolbox(documents_toolbox)
    toolbox_tag(DocumentToolbox.new(documents_toolbox, @project, current_user))
  end

  def documents_filter_js_tag
    content_for(:js) do
      javascript_tag
    end
  end
end
