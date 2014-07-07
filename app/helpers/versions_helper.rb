# Author: Nicolas Meylan
# Date: 5 mars 2013
# Encoding: UTF8
# File: versions_helper.rb

module VersionsHelper
  def versions_list_overview(collection, collection_detail)
    collection.collect do |version|
      version_overview(version, collection_detail[version.id][:closed_issues_count], collection_detail[version.id][:opened_issues_count], collection_detail[version.id][:percent])
    end.join.html_safe
  end


  def draw_roadmap(collection, collection_detail)
    collection.collect do |version|
      safe_concat version_overview(version, collection_detail[version.id][:closed_issues_count],
                                   collection_detail[version.id][:opened_issues_count], collection_detail[version.id][:percent])
      safe_concat version.display_description
      safe_concat content_tag :fieldset, class: 'margin_fieldset', &Proc.new {
        safe_concat content_tag :legend, &Proc.new {
          link_to glyph(t(:link_related_request), 'chevron-down'), '#', {:class => 'icon icon-expanded toggle', :id => "version-#{version.display_id}"}
        }
        safe_concat content_tag :div, class: "content version-#{version.id}", &Proc.new {
          content_tag :ul do
            collection_detail[version.id][:issues].collect do |issue|
              content_tag :li, "#{issue.tracker.name} ##{issue.id} : #{issue.caption}", class: "#{'close' if issue.status.is_closed?}"
            end.join.html_safe
          end
        }
      }
      content_tag :span, nil
    end.join.html_safe
  end

  def version_overview(version, closed_issues_count, opened_issues_count, percent)
    content_tag :div, class: 'version_overview' do
      safe_concat content_tag :h1, version.name, id: "v-#{version.display_id}"
      safe_concat content_tag :div, version.target_date, {class: 'version_due_date'}
      safe_concat clear_both
      safe_concat content_tag :span, class: 'progress_bar', &Proc.new {
        safe_concat content_tag :span, "&nbsp".html_safe, {class: 'progress', style: "width:#{percent}%"}
        safe_concat content_tag :span, "#{percent}%", {class: 'percent'}
      }
      safe_concat content_tag :span, class: 'requests_stats', &Proc.new {
        safe_concat content_tag :b, version.issues_count.to_s + ' '
        safe_concat t(:label_request_plural) + ', '
        safe_concat content_tag :b, closed_issues_count.to_s + ' '
        safe_concat t(:label_closed) + ', '
        safe_concat content_tag :b, opened_issues_count.to_s + ' '
        safe_concat t(:label_opened) + '.'
      }
      over_run = version.target_date.nil? || version.is_done ? 0 : (Date.today - version.target_date).to_i
      if over_run > 0
        safe_concat content_tag :span, %Q(#{t(:text_past_due)} #{t(:label_by)} #{over_run} #{t(:label_plural_day)}), {class: 'over_run text-alert octicon octicon-alert'}
      end
      safe_concat clear_both
    end

  end
end
