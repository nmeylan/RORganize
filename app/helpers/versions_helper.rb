# Author: Nicolas Meylan
# Date: 5 mars 2013
# Encoding: UTF8
# File: versions_helper.rb

module VersionsHelper
  # Build a list of versions.
  # @param [Array] collection of versions.
  def list(collection)
    content_tag :table, {class: 'version list'}, &Proc.new {
      safe_concat list_header
      safe_concat(collection.collect do |version|
        list_body(collection, version)
      end.join.html_safe)
    }
  end

  def list_body(collection, version)
    content_tag :tr, {class: 'odd-even', id: version.id} do
      safe_concat content_tag :td, version.edit_link, {class: 'list-left name'}
      safe_concat content_tag :td, version.start_date, {class: 'list-center start-date'}
      safe_concat content_tag :td, version.display_target_date, {class: 'list-center version'}
      safe_concat content_tag :td, version.is_done, {class: 'list-center is-done'}
      safe_concat list_sort_actions(collection, version)
      safe_concat content_tag :td, version.delete_link, {class: 'action'}
    end
  end

  def list_header
    content_tag :thead do
      content_tag :tr, class: 'header' do
        safe_concat content_tag :th, 'Name', {class: 'list-left'}
        safe_concat content_tag :th, 'Start date'
        safe_concat content_tag :th, 'Target date'
        safe_concat content_tag :th, 'Is done'
        safe_concat content_tag :th, nil
        safe_concat content_tag :th, nil
      end
    end
  end



  # Build a list of version overview report.
  # @param [Array] collection : array of versions.
  # @param [Hash] collection_detail : hash with following structure {version_id: {closed_issues_count: 'value', opened_issues_count: 'value', percent: 'value'}}
  def versions_list_overview(collection, collection_detail)
    collection.collect do |version|
      version_overview(version,
                       collection_detail[version.id][:closed_issues_count],
                       collection_detail[version.id][:opened_issues_count],
                       collection_detail[version.id][:percent])
    end.join.html_safe
  end

  # Build a render for the project road map.
  # @param [Array] collection : array of versions.
  # @param [Object] collection_detail
  # @param [Hash] collection_detail : hash with following structure {version_id: {closed_issues_count: 'value', opened_issues_count: 'value', percent: 'value'}}
  def draw_roadmap(collection, collection_detail)
    collection.collect do |version|
      content_tag :div, class: 'roadmap-version-block' do
        safe_concat version_overview(version,
                                     collection_detail[version.id][:closed_issues_count],
                                     collection_detail[version.id][:opened_issues_count],
                                     collection_detail[version.id][:percent])
        safe_concat version.display_description
        safe_concat version_detail_render(collection_detail, version)
      end
    end.join(content_tag :div, nil, class: 'separator').html_safe
  end

  def version_detail_render(collection_detail, version)
    if collection_detail[version.id][:issues]
      content_tag :fieldset do
        safe_concat version_detail_header_render(version)
        safe_concat version_detail_body_render(collection_detail, version)
      end
    end
  end

  def version_detail_body_render(collection_detail, version)
    content_tag :div, class: "content version-#{version.display_id}", &Proc.new {
      content_tag :ul do
        version_detail_issues_render(collection_detail, version)
      end
    }
  end

  def version_detail_issues_render(collection_detail, version)
    collection_detail[version.id][:issues].collect do |issue|
      content_tag :li, link_to("#{issue.tracker.name} ##{issue.id} : #{issue.caption}",
                               issue_path(version.project.slug, issue.id)),
                  class: "#{'close' if issue.status.is_closed?}"
    end.join.html_safe
  end

  def version_detail_header_render(version)
    content_tag :legend do
      link_to glyph(t(:link_related_request), 'chevron-down'), '#', {class: 'icon icon-expanded toggle', id: "version-#{version.display_id}"}
    end
  end

  # Build a render for version overview report.
  # @param [Version] version.
  # @param [Numeric] closed_issues_count.
  # @param [Numeric] opened_issues_count.
  # @param [Numeric] percent.
  def version_overview(version, closed_issues_count, opened_issues_count, percent)
    content_tag :div, class: 'version-overview' do
      safe_concat content_tag :h1, version.name, id: "v-#{version.display_id}"
      safe_concat content_tag :div, version.display_target_date, {class: 'version-due-date'}
      safe_concat clear_both
      safe_concat progress_bar_tag(percent)
      safe_concat version_overview_request_stats(closed_issues_count, opened_issues_count, version)
      safe_concat version_overview_over_run_tag(version)
      safe_concat clear_both
    end

  end

  def version_overview_over_run_tag(version)
    over_run = (version.target_date.nil? || version.is_done) ? 0 : (Date.today - version.target_date).to_i
    if over_run > 0
      content_tag :span, %Q(#{t(:text_past_due)} #{t(:label_by)} #{over_run} #{t(:label_plural_day)}), {class: 'over-run text-alert octicon octicon-alert'}
    end
  end

  def version_overview_request_stats(closed_issues_count, opened_issues_count, version)
    content_tag :span, class: 'requests-stats' do
      safe_concat content_tag :b, version.issues_count.to_s + ' '
      safe_concat t(:label_request_plural) + ', '
      safe_concat content_tag :b, closed_issues_count.to_s + ' '
      safe_concat t(:label_closed) + ', '
      safe_concat content_tag :b, opened_issues_count.to_s + ' '
      safe_concat t(:label_opened) + '.'
    end
  end
end
