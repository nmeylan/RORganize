# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: issues_overview_helper.rb
module Rorganize
  module Helpers
    module DocumentsHelpers
      module DocumentsFilterHelper
        # Build a json filter form.
        def documents_generics_form_to_json
          form_hash = {}
          document_filter = DocumentFilter.new(@project)
          filter_content_hash = document_filter.content
          hash_for_radio = filter_content_hash['hash_for_radio']
          hash_for_select = filter_content_hash['hash_for_select']
          form_hash = build_form_hash(hash_for_radio, hash_for_select)
          document_filter.build_json_form(form_hash)
        end
        def build_form_hash(hash_for_radio, hash_for_select)
          form_hash = {}
          form_hash['category'] = generic_filter(:simple_select, 'Category', 'category', hash_for_radio['category'], hash_for_select['category'])
          form_hash['created_at'] = generic_filter(:date, 'Created at', 'created_at', hash_for_radio['created'])
          form_hash['name'] = generic_filter(:text, 'Name', 'name', hash_for_radio['name'])
          form_hash['version'] = generic_filter(:simple_select, 'Version', 'version', hash_for_radio['version'], hash_for_select['version'])
          form_hash['updated_at'] = generic_filter(:date, 'Updated', 'updated_at', hash_for_radio['updated'])
          form_hash
        end
      end
    end
  end
end