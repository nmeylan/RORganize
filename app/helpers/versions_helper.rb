# Author: Nicolas Meylan
# Date: 5 mars 2013
# Encoding: UTF8
# File: versions_helper.rb

module VersionsHelper
  include Rorganize::Helpers::VersionsHelper
  # Build a list of versions.
  # @param [Array] collection of versions.
  def list(collection)
    content_tag :table, {class: 'version list'} do
      safe_concat list_header
      safe_concat list_body(collection)
    end
  end

  def list_body(collection)
    collection.collect do |version|
      list_row(collection, version)
    end.join.html_safe
  end

  def list_row(collection, version)
    content_tag :tr, {class: 'odd-even', id: version.id} do
      list_td version.edit_link, {class: 'list-left name'}
      list_td version.start_date, {class: 'list-center start-date'}
      list_td version.display_target_date, {class: 'list-center version'}
      list_td version.is_done, {class: 'list-center is-done'}
      safe_concat list_sort_actions(collection, version)
      list_td version.delete_link, {class: 'action'}
    end
  end

  def list_header
    content_tag :thead do
      content_tag :tr, class: 'header' do
        list_th 'Name', {class: 'list-left'}
        list_th 'Start date'
        list_th 'Target date'
        list_th 'Is done'
        list_th nil
        list_th nil
      end
    end
  end

  # Build a render for the project road map.
  # @param [Array] collection : array of versions.
  # @param [Hash] collection_detail : hash with following structure {version_id: {closed_issues_count: 'value', opened_issues_count: 'value', percent: 'value'}}
  def draw_roadmap(collection, collection_detail)
    collection.collect do |version|
      roadmap_version_block_render(collection_detail, version)
    end.join(content_tag :div, nil, class: 'separator').html_safe
  end

  # @param [Hash] collection_detail : hash with following structure {version_id: {closed_issues_count: 'value', opened_issues_count: 'value', percent: 'value'}}
  # @param [Version] version to render.
  def roadmap_version_block_render(collection_detail, version)
    content_tag :div, class: 'roadmap-version-block' do
      safe_concat call_version_overview(collection_detail, version)
      safe_concat version.display_description
      safe_concat version_detail_render(collection_detail, version)
    end
  end

end
