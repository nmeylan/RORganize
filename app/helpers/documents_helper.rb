# Author: Nicolas Meylan
# Date: 6 avr. 2013
# Encoding: UTF-8
# File: documents_helper.rb

module DocumentsHelper
  include Rorganize::MagicFilter

  def documents_generics_form_to_json
    form_hash = {}
    filter_content_hash = Document.filter_content_hash(@project)
    hash_for_radio = filter_content_hash['hash_for_radio']
    hash_for_select = filter_content_hash['hash_for_select']
    form_hash['category'] = generics_filter_simple_select('category', hash_for_radio['category'], hash_for_select['category'])
    form_hash['created_at'] = generics_filter_date_field('created_at', hash_for_radio['created'])
    form_hash['name'] = generics_filter_text_field('name', hash_for_radio['name'], 'Name')
    form_hash['version'] = generics_filter_simple_select('version', hash_for_radio['version'], hash_for_select['version'], 'Version')
    form_hash['updated_at'] = generics_filter_date_field('updated_at', hash_for_radio['updated'], 'Updated')
    form_hash.each { |k, v| v.gsub(/"/, "'").gsub(/\n/, '') }
    return form_hash.to_json
  end

  def documents_filter(hash)
    #attributes from db: get real attribute name to build query
    attributes = {
        'category' => 'category_id',
        'created_at' => 'created_at',
        'name' => 'name',
        'version' => 'version_id',
        'updated_at' => 'updated_at'
    }
    generics_filter(hash, attributes)
  end

  def documents_filter_js_tag
    content_for(:js) do
      javascript_tag
    end
  end
end
