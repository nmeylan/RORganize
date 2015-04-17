# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: version_details_helper.rb
module Rorganize
  module Helpers
    module VersionsHelpers
      module VersionDetailsHelper
        def version_detail_header_render(version)
          content_tag :legend do
            link_to glyph(t(:link_related_request), 'chevron-down'), '#', {class: 'icon icon-expanded toggle', id: "version-#{version.display_id}"}
          end
        end

        def version_detail_issue_render(issue, version)
          link_to("#{issue.tracker.name} ##{issue.sequence_id} : #{issue.caption}", issue_path(version.project.slug, issue))
        end

        def version_detail_issues_render(collection_detail, version)
          collection_detail[version.id][:issues].collect do |issue|
            content_tag :li, version_detail_issue_render(issue, version), class: "#{'close' if issue.status.is_closed?}"
          end.join.html_safe
        end

        def version_detail_body_render(collection_detail, version)
          content_tag :div, class: "content version-#{version.display_id}", &Proc.new {
            content_tag :ul do
              version_detail_issues_render(collection_detail, version)
            end
          }
        end

        # @param [Hash] collection_detail : hash with following structure {version_id: {closed_issues_count: 'value', opened_issues_count: 'value', percent: 'value'}}
        # @param [Version] version to render detail.
        def version_detail_render(collection_detail, version)
          if collection_detail[version.id][:issues]
            content_tag :fieldset do
              concat version_detail_header_render(version)
              concat version_detail_body_render(collection_detail, version)
            end
          end
        end
      end
    end
  end
end