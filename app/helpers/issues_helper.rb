require 'issues/issue_filter'
require 'issues/issue_toolbox'
module IssuesHelper
  include CommentsHelper
  include IssuesHelpers::IssuesOverviewHelper
  include IssuesHelpers::IssuesFilterHelper

  def list(collection)
    generic_list(collection, {class: 'issue list', 'data-link' => toolbox_project_issues_path(@project.slug)})
  end

  def list_row(issue)
    disabled_class = !issue.user_allowed_to_edit? ? 'disabled-toolbox' : ''
    content_tag :tr, class: "has-context-menu odd-even issue-tr #{disabled_class}" do
      list_td(check_box_tag("issue-#{issue.sequence_id.to_s}", issue.sequence_id, false, disabled: !issue.user_allowed_to_edit?), class: 'cell-checkbox')
      list_td issue.sequence_id, class: 'list-center id'
      list_td issue.tracker_str, class: 'list-center tracker'
      list_td issue.show_link, {class: 'name', id: issue.sequence_id}
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
    list_td issue.display_estimated_time, class: 'list-center'
  end

  def issue_overview_list_type_rows(issue)
    list_td issue.display_category, class: 'list-center category'
    list_td issue.display_updated_at, class: 'list-center updated-at'
    list_td issue.display_done_progression, {class: 'list-center done tooltipped tooltipped-s', label: "#{issue.done}%"}
    list_td issue.checklist_progression, class: 'icon-information'
    list_td issue.comment_presence_indicator, class: 'icon-information'
    list_td issue.attachment_presence_indicator, class: 'icon-information'
  end

  def list_header
    content_tag :thead do
      content_tag :tr, class: 'header' do
        list_th link_to(glyph('', 'check'), '#', {class: 'icon-checked', id: 'check-all', 'cb_checked' => 'b', data: {toggle: "check-all"}})
        list_th sortable('issues.sequence_id', '#')
        list_th sortable('trackers.name', Issue.human_attribute_name(:tracker_id))
        list_th sortable('issues.subject', Issue.human_attribute_name(:subject)), {class: 'list-left no-padding-left'}
        list_th sortable('users.name', Issue.human_attribute_name(:assigned_to_id))
        list_th sortable('issues_statuses.enumeration_id', Issue.human_attribute_name(:status_id))
        list_th sortable('versions.name', Issue.human_attribute_name(:version_id))
        issue_gantt_list_type_headers
        issue_overview_list_type_headers
        issue_list_indicators_header
      end
    end
  end

  def issue_gantt_list_type_headers
    if is_list_displayed_with_type?(:gantt)
      list_th sortable('issues.start_date', Issue.human_attribute_name(:start_date))
      list_th sortable('issues.due_date', Issue.human_attribute_name(:due_date))
      list_th sortable('issues.estimated_time', Issue.human_attribute_name(:estimated_time))
    end
  end

  def issue_overview_list_type_headers
    if is_list_displayed_with_type?(:overview)
      list_th sortable('categories.name', Issue.human_attribute_name(:category))
      list_th sortable('issues.updated_at', Issue.human_attribute_name(:updated_at))
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
    subnav_tag('pull-right',
               'issue-list-type-nav',
               issue_list_type_nav_item('overview', 'three-bars', :overview, t(:text_issue_list_type_overview)),
               issue_list_type_nav_item('gantt', 'clock', :gantt, t(:text_issue_list_type_gantt)))
  end

  def issue_list_type_nav_item(label, glyph, type, text = '')
    {caption: glyph(label, glyph),
     path: project_issues_path(@project.slug, list_type: type),
     options: {class: "#{'active' if is_list_displayed_with_type?(type.to_sym)} btn btn-default tooltipped tooltipped-s", label: text}}
  end

  # Build a toolbox render for issue toolbox.
  # @param [Array] collection : a collection of selected Issues that will be bulk edited.
  def issue_toolbox(collection)
    toolbox_tag(IssueToolbox.new(collection, @project, User.current))
  end

end
