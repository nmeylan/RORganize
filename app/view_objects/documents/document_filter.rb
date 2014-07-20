# Author: Nicolas Meylan
# Date: 26.06.14
# Encoding: UTF-8
# File: document_filter.rb

class DocumentFilter
  attr_reader :content

  def initialize(project)
    @project = project
    @content = build_filter
  end

  #Return a hash with the content requiered for the filter's construction
  #Can define 2 type of filters:
  #Radio : with values : all - equal/contains - different/not contains
  #Select : for attributes which only defined values : e.g : version => [1,2,3]
  def build_filter
    content_hash = {}
    content_hash['hash_for_select'] = {}
    content_hash['hash_for_radio'] = Hash.new { |k, v| k[v] = [] }
    content_hash['hash_for_radio']['name'] = ['all', 'contains', 'not_contains']
    content_hash['hash_for_select']['category'] = @project.categories.collect { |category| [category.name, category.id] }
    content_hash['hash_for_radio']['category'] = %w(all equal different)
    content_hash['hash_for_radio']['created'] = %w(all equal superior inferior today)
    content_hash['hash_for_select']['version'] = @project.versions.collect { |version| [version.name, version.id] }
    content_hash['hash_for_select']['version'] << %w(Unplanned NULL)
    content_hash['hash_for_radio']['version'] = %w(all equal different)
    content_hash['hash_for_radio']['updated'] = %w(all equal superior inferior today)
    content_hash
  end
end