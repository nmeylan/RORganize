# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: version_details_helper.rb
module Rorganize
  module Helpers
    module VersionsHelpers
      module VersionOverviewHelper
        # Build a list of version overview report.
        # @param [Array] collection : array of versions.
        # @param [Hash] collection_detail : hash with following structure {version_id: {closed_issues_count: 'value', opened_issues_count: 'value', percent: 'value'}}
        def versions_list_overview(collection, collection_detail)
          collection.collect do |version|
            call_version_overview(collection_detail, version)
          end.join.html_safe
        end

        def call_version_overview(collection_detail, version)
          version_overview(version,
                           collection_detail[version.id][:closed_issues_count],
                           collection_detail[version.id][:opened_issues_count],
                           collection_detail[version.id][:percent])
        end

        # Build a render for version overview report.
        # @param [Version] version.
        # @param [Numeric] closed_issues_count.
        # @param [Numeric] opened_issues_count.
        # @param [Numeric] percent.
        def version_overview(version, closed_issues_count, opened_issues_count, percent)
          content_tag :div, class: 'version-overview' do
            concat content_tag :h1, version.name, id: "v-#{version.display_id}"
            concat version_dates_header(version)
            concat clear_both
            concat progress_bar_tag(percent)
            concat version_overview_request_stats(closed_issues_count, opened_issues_count)
            concat version_overview_over_run_tag(version)
            concat clear_both
          end

        end

        def version_dates_header(version)
          unless version.id.nil?
            content_tag :div, class: 'version-dates-header' do
              concat_span_tag glyph(' ', 'calendar')
              concat_span_tag version.display_start_date, {class: 'version-start-date'}
              concat_span_tag '-', {class: 'version-dates-separator'}
              concat_span_tag version.display_target_date, {class: 'version-due-date'}
            end
          end
        end

        def version_overview_over_run_tag(version)
          over_run = (version.target_date.nil? || version.is_done) ? 0 : (Date.today - version.target_date).to_i
          if over_run > 0
            content_tag :span, {class: 'over-run text-alert'} do
              concat content_tag :span, nil, {class: 'octicon octicon-alert'}
              concat %Q(#{t(:text_past_due)} #{t(:label_by)} #{over_run} #{t(:label_plural_day)})
            end
          end
        end

        def version_overview_request_stats(closed_issues_count, opened_issues_count)
          content_tag :span, class: 'requests-stats' do
            concat content_tag :b, "#{closed_issues_count + opened_issues_count} "
            concat t(:label_request_plural) + ', '
            concat content_tag :b, "#{closed_issues_count.to_s} "
            concat t(:label_closed) + ', '
            concat content_tag :b, "#{opened_issues_count.to_s} "
            concat t(:label_opened) + '.'
          end
        end
      end
    end
  end
end