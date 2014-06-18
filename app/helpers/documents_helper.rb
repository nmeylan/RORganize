# Author: Nicolas Meylan
# Date: 6 avr. 2013
# Encoding: UTF-8
# File: documents_helper.rb

module DocumentsHelper

  def documents_generics_form_to_json
    form_hash = {}
    filter_content_hash = Document.filter_content_hash(@project)
    hash_for_radio = filter_content_hash['hash_for_radio']
    hash_for_select = filter_content_hash['hash_for_select']
    form_hash['category'] = generic_filter(:simple_select, 'Category', 'category', hash_for_radio['category'], hash_for_select['category'])
    form_hash['created_at'] = generic_filter(:date, 'Created at', 'created_at', hash_for_radio['created'])
    form_hash['name'] = generic_filter(:text, 'Name', 'name', hash_for_radio['name'])
    form_hash['version'] = generic_filter(:simple_select, 'Version','version', hash_for_radio['version'], hash_for_select['version'])
    form_hash['updated_at'] = generic_filter(:date, 'Updated','updated_at', hash_for_radio['updated'])
    form_hash.each { |_, v| v.gsub(/"/, "'").gsub(/\n/, '') }
    form_hash.to_json
  end

  def documents_filter_js_tag
    content_for(:js) do
      javascript_tag
    end
  end
end
