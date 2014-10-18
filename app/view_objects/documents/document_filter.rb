# Author: Nicolas Meylan
# Date: 26.06.14
# Encoding: UTF-8
# File: document_filter.rb
require 'shared/Filter'
require 'projects/project_item_filter_part'
class DocumentFilter < ProjectItemFilterPart
  attr_reader :content

  #Return a hash with the content requiered for the filter's construction
  #Can define 2 type of filters:
  #Radio : with values : all - equal/contains - different/not contains
  #Select : for attributes which only defined values : e.g : version => [1,2,3]
  # @return [Hash] with the content requiered for the filter's construction
  def build_filter
    content_hash = {}
    content_hash['hash_for_select'] = {}
    content_hash['hash_for_radio'] = Hash.new { |k, v| k[v] = [] }
    content_hash['hash_for_radio']['name'] = %w(all contains not_contains)
    category_filter(content_hash)
    version_filter(content_hash)
    updated_at_filter(content_hash)
    created_at_filter(content_hash)
    content_hash
  end
end