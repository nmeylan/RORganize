# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: issues_overview_helper.rb
module Rorganize
  module Helpers
    module IssuesHelpers
      module IssuesOverviewHelper
        # Build a render for issues overview report.
        # @param [Array] groups : array of groups that contains issues.
        # @param [String] title : title of the report. (e.g : Opened assigned issue, Closed issues)
        # @param [String] group_name : name of the group (e.g: project)
        # @param [String] group_class_name : css class for the group.
        def display_overview_groups(groups, title = nil, optional_group_name = nil, group_class_name = nil)
          groups.collect do |group_hash|
            group_hash.collect do |group_name, group|
              group_name_string = group_name_string(optional_group_name, group_name)
              t = overview_group_title(group_name, title)
              display_overview_group_by("#{t} : By #{group_name_string}", group, group_name, !group_name.eql?(:status), group_class_name)
            end.join.html_safe
          end.join.html_safe
        end

        def group_name_string(optional_group_name, group_name)
          optional_group_name.nil? ? group_name.to_s.capitalize.tr('_', ' ') : optional_group_name
        end

        def overview_group_title(k, title)
          if title.nil?
            k.eql?(:status) ? 'Issues' : 'Opened issues'
          else
            title
          end
        end

        # Build a render for group of issues.
        # @param [String] title : title of the report (e.g : Opened assigned issue : by project)
        # @param [Array] group : the group of issues
        # @param [Symbol] group_name : the symbol of the object attribute (e.g :assigned_to, :status)
        # @param [Boolean] only_opened_issues : true display report only for opened issues else display report for all issues.
        # @param [String] group_class_name : css class for the group.
        def display_overview_group_by(title, group, group_name, only_opened_issues = true, group_class_name = nil)
          class_name = group_class_name.nil? ? 'issues-overview-group' : group_class_name
          content_tag :div, class: class_name do
            concat content_tag :h2, title, class: "#{class_name} title"
            if group.any?
              concat overview_table(class_name, group, group_name, only_opened_issues)
            else
              concat no_data(t(:text_no_issues), 'issue-opened')
            end
          end
        end

        # @param [String] class_name css.
        # @param [Array] group : the group of issues
        # @param [Symbol] group_name : the symbol of the object attribute (e.g :assigned_to, :status)
        # @param [Boolean] only_opened_issues : true display report only for opened issues else display report for all issues.
        def overview_table(class_name, group, group_name, only_opened_issues)
          content_tag :table, class: class_name do
            concat overview_table_header(class_name)
            display_overview_rows(group, group_name, only_opened_issues)
            na = no_affected_row(group)
            concat display_overview_row(na, group_name, only_opened_issues) if na
          end
        end

        # Build overview report rows.
        # @param [Array] group : the group of issues
        # @param [Symbol] group_name : the symbol of the object attribute (e.g :assigned_to, :status)
        # @param [Boolean] only_opened_issues : true display report only for opened issues else display report for all issues.
        def display_overview_rows(group, group_name, only_opened_issues)
          group.sort_by { |e| e[:caption] }.collect do |element|
            select_overview_row_type(element, group_name, only_opened_issues)
          end.join.html_safe
        end

        # Select and build the right row to display.
        # @param [Hash] element : see #IssueOverviewHash.
        # @param [Symbol] group_name : the symbol of the object attribute (e.g :assigned_to, :status)
        # @param [Boolean] only_opened_issues : true display report only for opened issues else display report for all issues.
        def select_overview_row_type(element, group_name, only_opened_issues)
          if element[:id].eql?('NULL')
            element
          else
            concat display_overview_row(element, group_name, only_opened_issues)
          end
        end

        # Return the non affected row.
        # @param [Array] group group of row (e.g : all versions row (version1, version2, unplanned))
        # @return [Hash] element : see #IssueOverviewHash.
        def no_affected_row(group)
          group.detect { |element| element[:id].eql?('NULL') }
        end

        # @param [String] class_name : css class name.
        def overview_table_header(class_name)
          content_tag :tr, class: "#{class_name} header" do
            concat content_tag :th, t(:field_name), class: 'caption'
            concat content_tag :th, t(:label_issue_plural), class: 'number'
            concat content_tag :th, t(:label_percentage), class: 'percentage'
          end
        end

        # Build a row for the overview report.
        # @param [Hash] element : see #IssueOverviewHash.
        # @param [Symbol] group_name : the symbol of the object attribute (e.g :assigned_to, :status)
        # @param [Boolean] only_opened_issues : true display report only for opened issues else display report for all issues.
        def display_overview_row(element, group_name, only_opened_issues)
          content_tag :tr, class: 'issues-overview-group body' do
            concat select_filter_link(element, group_name, only_opened_issues)
            concat content_tag :td, element[:count], class: 'number'
            concat content_tag :td, progress_bar_tag(element[:percent]), class: 'percentage'
          end
        end

        def select_filter_link(element, group_name, only_opened_issues)
          if only_opened_issues
            content_tag :td,
                        filter_link(element[:caption],
                                    element[:project],
                                    [group_name, :status],
                                    {group_name => {operator: :equal, value: [element[:id]]}, status: {operator: :open}}),
                        class: 'caption'
          else
            content_tag :td,
                        filter_link(element[:caption],
                                    element[:project],
                                    [group_name],
                                    {group_name => {operator: :equal, value: [element[:id]]}}),
                        class: 'caption'
          end
        end

        # Build a link to issues list with given filter.
        # @param [String] label of the link.
        # @param [String] project_slug : the slug of the project.
        # @param [Array] filter_list : list of filtered field(attribute).
        # @param [Hash] filter : hash with following structure {attribute: {operator: 'operator', value: ['values']}}.
        def filter_link(label, project_slug, filter_list, filter)
          link_to label, issues_path(project_slug, {type: :filter, filters_list: filter_list, filter: filter})
        end
      end
    end
  end
end