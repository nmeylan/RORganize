require 'issues/issue_filter'
require 'issues/issue_toolbox'
module IssuesHelper
  include CommentsHelper
  include Rorganize::Helpers::IssuesHelper

  def list(collection)
    generic_list(collection, {class: 'issue list', 'data-link' => toolbox_issues_path(@project.slug)})
  end

  def list_row(issue)
    content_tag :tr, class: "has-context-menu odd-even issue-tr" do
      list_td(check_box_tag("issue-#{issue.id.to_s}", issue.id), class: 'cell-checkbox')
      list_td issue.id, class: 'list-center id'
      list_td issue.tracker_str, class: 'list-center tracker'
      list_td issue.show_link, {class: 'name', id: issue.id}
      list_td issue.display_assigned_to, class: 'list-center assigned-to'
      list_td issue.display_status, class: 'list-center status'
      list_td issue.display_version, class: 'list-center version'
      issue_list_right_columns(issue)
    end
  end

  def issue_list_right_columns(issue)
    is_list_displayed_with_type?(:gantt) ? issue_gantt_list_type_rows(issue) : issue_overview_list_type_rows(issue)
  end

  def issue_gantt_list_type_rows(issue)
    list_td issue.display_start_date, class: 'list-center'
    list_td issue.display_due_date, class: 'list-center'
    list_td issue.estimated_time, class: 'list-center'
  end

  def issue_overview_list_type_rows(issue)
    list_td issue.display_category, class: 'list-center category'
    list_td issue.display_updated_at, class: 'list-center updated-at'
    list_td issue.display_done_progression, {class: 'list-center done tooltipped tooltipped-s', label: "#{issue.done}%"}
    list_td issue.checklist_progression, class: 'icon-information'
    list_td issue.comment_presence_indicator, class: 'icon-information'
    list_td issue.attachment_presence_indicator, class: 'icon-information'
    issue_list_indicators_rows(issue)
  end

  def list_header
    content_tag :thead do
      content_tag :tr, class: 'header' do
        list_th link_to(glyph('', 'check'), '#', {class: 'icon-checked', id: 'check-all', 'cb_checked' => 'b'})
        list_th sortable('issues.id', '#')
        list_th sortable('trackers.name', 'Tracker')
        list_th sortable('issues.subject', 'Subject'), {class: 'list-left no-padding-left'}
        list_th sortable('users.name', 'Assigned to')
        list_th sortable('issues_statuses.enumeration_id', 'Status')
        list_th sortable('versions.name', 'Target phase')
        issue_gantt_list_type_headers
        issue_overview_list_type_headers
        issue_list_indicators_header
      end
    end
  end

  def issue_gantt_list_type_headers
    if is_list_displayed_with_type?(:gantt)
      list_th sortable('issues.start_date', 'Start date')
      list_th sortable('issues.due_date', 'Due date')
      list_th sortable('issues.estimated_time', 'Estimated time')
    end
  end

  def issue_overview_list_type_headers
    if is_list_displayed_with_type?(:overview)
      list_th sortable('categories.name', 'Category')
      list_th sortable('issues.updated_at', 'Last update')
    end
  end

  def issue_list_indicators_header
    if is_list_displayed_with_type?(:overview)
      list_th sortable('issues.done', 'Done')
      list_th nil, {class: 'optional-cell'}
      list_th nil, {class: 'optional-cell'}
      list_th nil, {class: 'optional-cell'}
    end
  end

  def is_list_displayed_with_type?(type)
    @sessions[:list_type].eql?(type)
  end

  def issue_list_type_nav
    subnav_tag('subnav-right',
               'issue-list-type-nav',
               issue_list_type_nav_item('overview', 'three-bars', :overview, t(:text_issue_list_type_overview)),
               issue_list_type_nav_item('gantt', 'clock', :gantt, t(:text_issue_list_type_gantt)))
  end

  def issue_list_type_nav_item(label, glyph, type, text = '')
    {caption: glyph(label, glyph),
     path: issues_path(@project.slug, list_type: type),
     options: {class: "#{'selected' if is_list_displayed_with_type?(type.to_sym)} subnav-item tooltipped tooltipped-s", label: text}}
  end

# Build a toolbox render for issue toolbox.
# @param [IssueToolbox] issues_toolbox
  def issue_toolbox(issues_toolbox)
    toolbox_tag(IssueToolbox.new(issues_toolbox, @project, User.current))
  end

end
