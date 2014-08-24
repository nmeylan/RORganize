require 'issues/issue_filter'
require 'issues/issue_toolbox'
module IssuesHelper
  include CommentsHelper

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

  def issues_activities_text_builder(journal, specified_project = true)
    content_tag :p do
      if journal.action_type.eql?('updated') || journal.action_type.eql?('created')
        if journal.details.empty? && !journal.notes.nil? && !journal.notes.eql?('')
          safe_concat content_tag :span, nil, {class: 'octicon octicon-comment'}
          safe_concat "#{journal.user.name} #{t(:label_commented_lower_case)} "
        else
          safe_concat content_tag :span, nil, {class: 'octicon octicon-pencil'} if journal.action_type.eql?('updated')
          safe_concat content_tag :span, nil, {class: 'octicon octicon-diff-added'} if journal.action_type.eql?('created')
          safe_concat "#{journal.user.name} #{t(:label_updated_lower_case)} "
        end
        safe_concat content_tag :b, "#{journal.journalizable_type} "
        safe_concat link_to(journal.journalizable_id, issue_path(journal.project.slug, journal.journalizable_id))
        if journal.project_id && specified_project
          safe_concat " #{t(:label_at)} "
          safe_concat content_tag :b, link_to(journal.project.slug, overview_projects_path(journal.project.slug))
        end
      elsif journal.action_type.eql?('deleted')
        safe_concat content_tag :span, nil, {class: 'octicon octicon-trashcan'}
        safe_concat "##{journal.user.name} #{t(:label_deleted_lower_case)} "
        safe_concat content_tag :b, "#{journal.journalizable_type} ##{journal.journalizable_id}"
        if journal.project_id && specified_project
          safe_concat "#{t(:label_at)} "
          safe_concat content_tag :b, link_to(journal.project.slug, overview_projects_path(journal.project.slug))
        end
      end
    end
  end


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
        safe_concat content_tag :th, nil
        safe_concat content_tag :th, nil
      }
      safe_concat(collection.collect do |issue|
        content_tag :tr, class: "has_context_menu odd_even issue_tr #{'close' if issue.status.is_closed?}" do
          safe_concat content_tag :td, check_box_tag("issue-#{issue.id.to_s}", issue.id)
          safe_concat content_tag :td, issue.id, class: 'list_center id'
          safe_concat content_tag :td, issue.tracker, class: 'list_center tracker'
          safe_concat content_tag :td, link_to(issue.caption, issue_path(@project.slug, issue.id)), {class: 'name', id: issue.id}
          safe_concat content_tag :td, issue.assigned_to, class: 'list_center assigned_to'
          safe_concat content_tag :td, issue.status.caption, class: 'list_center status'
          safe_concat content_tag :td, issue.category, class: 'list_center category'
          safe_concat content_tag :td, issue.version, class: 'list_center version'
          safe_concat content_tag :td, issue.due_date, class: 'list_center due_date'
          safe_concat content_tag :td, issue.done, class: 'list_center done'
          safe_concat content_tag :td, issue.link_checklist_overlay
          safe_concat content_tag :td, issue.attachment_presence_indicator
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

  def issue_toolbox(issues_toolbox)
    toolbox_tag(IssueToolbox.new(issues_toolbox, @project, User.current))
  end

  def display_overview_groups(groups)
    groups.collect do |group_hash|
      group_hash.collect do |k, v|
        title = k.eql?(:status) ? 'Issues' : 'Opened issues'
        display_overview_group_by("#{title} : By #{k.to_s.capitalize.gsub(/_/, ' ')}", v, k, !k.eql?(:status))
      end.join.html_safe
    end.join.html_safe
  end

  def display_overview_group_by(title, group, group_name, only_opened_issues = true)
    content_tag :div, class: 'issues_overview_group' do
      safe_concat content_tag :h2, title, class: 'issues_overview_group title'
      safe_concat content_tag :table, class: 'issues_overview_group', &Proc.new {
        safe_concat content_tag :tr, class: 'issues_overview_group header', &Proc.new {
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
    end
  end

  def display_overview_row(element, group_name, only_opened_issues)
    safe_concat content_tag :tr, class: 'issues_overview_group body', &Proc.new {
      if only_opened_issues
        safe_concat content_tag :td, filter_link(element[:caption], @project.slug, [group_name, :status], {group_name => {operator: :equal, value: [element[:id]]}, status: {operator: :open}}), class: 'caption'
      else
        safe_concat content_tag :td, filter_link(element[:caption], @project.slug, [group_name], {group_name => {operator: :equal, value: [element[:id]]}}), class: 'caption'
      end
      safe_concat content_tag :td, element[:count], class: 'number'
      safe_concat content_tag :td, progress_bar_tag(element[:percent]), class: 'percentage'
    }
  end

  def filter_link(label, project_slug, filter_list, filter)
    link_to label, issues_path(project_slug, {type: :filter, filters_list: filter_list, filter: filter})
  end

end
