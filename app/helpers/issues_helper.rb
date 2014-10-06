require 'issues/issue_filter'
require 'issues/issue_toolbox'
module IssuesHelper
  include CommentsHelper

  # Build a json filter form.
  def issues_generics_form_to_json
    form_hash = {}
    filter_content_hash = IssueFilter.new(@project).content
    hash_for_radio = filter_content_hash['hash_for_radio']
    hash_for_select = filter_content_hash['hash_for_select']
    form_hash['assigned_to'] = generic_filter(:simple_select, 'Assigned to', 'assigned_to', hash_for_radio['assigned'], hash_for_select['assigned'], true, nil)
    form_hash['author'] = generic_filter(:simple_select, 'Author', 'author', hash_for_radio['author'], hash_for_select['author'])
    form_hash['category'] = generic_filter(:simple_select, 'Category', 'category', hash_for_radio['category'], hash_for_select['category'])
    form_hash['created_at'] = generic_filter(:date, 'Created at', 'created_at', hash_for_radio['created'])
    form_hash['done'] = generic_filter(:simple_select, 'Done', 'done', hash_for_radio['done'], hash_for_select['done'], false, 'cbb-small')
    form_hash['due_date'] = generic_filter(:date, 'Due date', 'due_date', hash_for_radio['due_date'])
    form_hash['start_date'] = generic_filter(:date, 'Start date', 'start_date', hash_for_radio['start'])
    form_hash['status'] = generic_filter(:simple_select, 'Status', 'status', hash_for_radio['status'], hash_for_select['status'])
    form_hash['subject'] = generic_filter(:text, 'Subject', 'subject', hash_for_radio['subject'])
    form_hash['tracker'] = generic_filter(:simple_select, 'Tracker', 'tracker', hash_for_radio['tracker'], hash_for_select['tracker'])
    form_hash['version'] = generic_filter(:simple_select, 'Version', 'version', hash_for_radio['version'], hash_for_select['version'])
    form_hash['updated_at'] = generic_filter(:date, 'Updated at', 'updated_at', hash_for_radio['updated'])
    form_hash.each { |_, v| v.gsub(/"/, "'").gsub(/\n/, '') }
    form_hash.to_json
  end

  # Build a list of issues.
  # @param [Array] collection of issues.
  def list(collection)
    content_tag :table, {class: 'issue list', 'data-link' => toolbox_issues_path(@project.slug)}, &Proc.new {
      safe_concat content_tag :tr, class: 'header', &Proc.new {
        safe_concat content_tag :th, link_to(glyph('', 'check'), '#', {:class => 'icon-checked', :id => 'check_all', 'cb_checked' => 'b'})
        safe_concat content_tag :th, sortable('issues.id', '#')
        safe_concat content_tag :th, sortable('trackers.name', 'Tracker')
        safe_concat content_tag :th, sortable('issues.subject', 'Subject')
        safe_concat content_tag :th, sortable('users.name', 'Assigned to')
        safe_concat content_tag :th, sortable('issues_statuses.enumeration_id', 'Status')
        safe_concat content_tag :th, sortable('categories.name', 'Category')
        safe_concat content_tag :th, sortable('versions.name', 'Target phase')
        safe_concat content_tag :th, sortable('issues.due_date', 'Due date')
        safe_concat content_tag :th, sortable('issues.done', 'Done')
        safe_concat content_tag :th, nil, {class: 'optional_cell'}
        safe_concat content_tag :th, nil, {class: 'optional_cell'}
        safe_concat content_tag :th, nil, {class: 'optional_cell'}
      }
      safe_concat(collection.collect do |issue|
        content_tag :tr, class: "has_context_menu odd_even issue_tr #{'close' if issue.status.is_closed?}" do
          safe_concat content_tag :td, check_box_tag("issue-#{issue.id.to_s}", issue.id), {class: 'cell_checkbox'}
          safe_concat content_tag :td, issue.id, class: 'list_center id'
          safe_concat content_tag :td, issue.tracker_str, class: 'list_center tracker'
          safe_concat content_tag :td, link_to(issue.resized_caption(35), issue_path(@project.slug, issue.id)), {class: 'name', id: issue.id}
          safe_concat content_tag :td, issue.assigned_to, class: 'list_center assigned_to'
          safe_concat content_tag :td, issue.status.caption, class: 'list_center status'
          safe_concat content_tag :td, issue.category, class: 'list_center category'
          safe_concat content_tag :td, issue.version_str, class: 'list_center version'
          safe_concat content_tag :td, issue.due_date, class: 'list_center due_date'
          safe_concat content_tag :td, issue.done, class: 'list_center done'
          safe_concat content_tag :td, issue.checklist_progression, class: 'icon_information'
          safe_concat content_tag :td, issue.comment_presence_indicator, class: 'icon_information'
          safe_concat content_tag :td, issue.attachment_presence_indicator, class: 'icon_information'
        end
      end.join.html_safe)
    }
  end

  def simple_list(collection)
    content_tag :table, {class: 'issue list'}, &Proc.new {
      safe_concat content_tag :tr, class: 'header', &Proc.new {
        safe_concat content_tag :th, '#'
        safe_concat content_tag :th, 'Tracker'
        safe_concat content_tag :th, 'Project'
        safe_concat content_tag :th, 'Subject'
        safe_concat content_tag :th, 'Status'
        safe_concat content_tag :th, 'Done'
      }
      safe_concat(collection.collect do |issue|
        content_tag :tr, class: "odd_even issue_tr #{'close' if issue.status.is_closed?}" do
          safe_concat content_tag :td, issue.id, class: 'list_center id'
          safe_concat content_tag :td, issue.tracker, class: 'list_center tracker'
          safe_concat content_tag :td, link_to(issue.project.name, overview_projects_path(issue.project.slug)), class: 'list_center project'
          safe_concat content_tag :td, link_to(issue.caption, issue_path(issue.project.slug, issue.id)), {class: 'name', id: issue.id}
          safe_concat content_tag :td, issue.status.caption, class: 'list_center status'
          safe_concat content_tag :td, issue.done, class: 'list_center done'
        end
      end.join.html_safe)
    }
  end

  # Build a toolbox render for issue toolbox.
  # @param [IssueToolbox] issues_toolbox
  def issue_toolbox(issues_toolbox)
    toolbox_tag(IssueToolbox.new(issues_toolbox, @project, User.current))
  end

  # Build a render for issues overview report.
  # @param [Array] groups : array of groups that contains issues.
  # @param [String] title : title of the report. (e.g : Opened assigned issue, Closed issues)
  # @param [String] group_name : name of the group (e.g: project)
  # @param [String] group_class_name : css class for the group.
  def display_overview_groups(groups, title = nil, group_name = nil, group_class_name = nil)
    groups.collect do |group_hash|
      group_hash.collect do |k, v|
        gn = group_name.nil? ? k.to_s.capitalize.gsub(/_/, ' ') : group_name
        t = if title.nil? then
              k.eql?(:status) ? 'Issues' : 'Opened issues'
            else
              title
            end
        display_overview_group_by("#{t} : By #{gn}", v, k, !k.eql?(:status), group_class_name)
      end.join.html_safe
    end.join.html_safe
  end

  # Build a render for group of issues.
  # @param [String] title : title of the report (e.g : Opened assigned issue : by project)
  # @param [Array] group : the group of issues
  # @param [Symbol] group_name : the symbol of the object attribute (e.g :assigned_to, :status)
  # @param [Boolean] only_opened_issues : true display report only for opened issues else display report for all issues.
  # @param [String] group_class_name : css class for the group.
  def display_overview_group_by(title, group, group_name, only_opened_issues = true, group_class_name = nil)
    class_name = group_class_name.nil? ? 'issues_overview_group' : group_class_name
    content_tag :div, class: class_name do
      safe_concat content_tag :h2, title, class: "#{class_name} title"
      if group.any?
        safe_concat content_tag :table, class: class_name, &Proc.new {
          safe_concat content_tag :tr, class: "#{class_name} header", &Proc.new {
            safe_concat content_tag :th, t(:field_name), class: 'caption'
            safe_concat content_tag :th, t(:label_issue_plural), class: 'number'
            safe_concat content_tag :th, t(:label_percentage), class: 'percentage'
          }
          na = nil
          group.sort_by { |e| e[:caption] }.collect do |element|
            if element[:id].eql?('NULL')
              na = element
            else
              display_overview_row(element, group_name, only_opened_issues)
            end
          end.join.html_safe
          display_overview_row(na, group_name, only_opened_issues) if na
        }
      else
        safe_concat no_data(t(:text_no_issues), 'issue_opened')
      end
    end
  end

  # Build a row for the overview report.
  # @param [Hash] element : see #IssueOverviewHash.
  # @param [Symbol] group_name : the symbol of the object attribute (e.g :assigned_to, :status)
  # @param [Boolean] only_opened_issues : true display report only for opened issues else display report for all issues.
  def display_overview_row(element, group_name, only_opened_issues)
    safe_concat content_tag :tr, class: 'issues_overview_group body', &Proc.new {
      if only_opened_issues
        safe_concat content_tag :td, filter_link(element[:caption], element[:project], [group_name, :status], {group_name => {operator: :equal, value: [element[:id]]}, status: {operator: :open}}), class: 'caption'
      else
        safe_concat content_tag :td, filter_link(element[:caption], element[:project], [group_name], {group_name => {operator: :equal, value: [element[:id]]}}), class: 'caption'
      end
      safe_concat content_tag :td, element[:count], class: 'number'
      safe_concat content_tag :td, progress_bar_tag(element[:percent]), class: 'percentage'
    }
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
