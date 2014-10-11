require 'issues/issue_filter'
require 'issues/issue_toolbox'
module IssuesHelper
  include CommentsHelper
  include Rorganize::Helpers::IssuesHelper

  # Build a list of issues.
  # @param [Array] collection of issues.
  def list(collection)
    content_tag :table, {class: 'issue list', 'data-link' => toolbox_issues_path(@project.slug)} do
      safe_concat list_header
      safe_concat list_body(collection)
    end
  end

  def list_body(collection)
    collection.collect do |issue|
      list_row(issue)
    end.join.html_safe
  end

  def list_row(issue)
    content_tag :tr, class: "has-context-menu odd-even issue-tr" do
      list_td(check_box_tag("issue-#{issue.id.to_s}", issue.id), class: 'cell-checkbox')
      list_td issue.id, class: 'list-center id'
      list_td issue.tracker_str, class: 'list-center tracker'
      list_td issue.show_link, {class: 'name', id: issue.id}
      list_td issue.display_assigned_to, class: 'list-center assigned-to'
      list_td issue.display_status, class: 'list-center status'
      list_td issue.display_category, class: 'list-center category'
      list_td issue.display_version, class: 'list-center version'
      list_td issue.due_date, class: 'list-center due-date'
      list_td issue.display_done_progression, {class: 'list-center done tooltipped tooltipped-s', label: "#{issue.done}%"}
      list_td issue.checklist_progression, class: 'icon-information'
      list_td issue.comment_presence_indicator, class: 'icon-information'
      list_td issue.attachment_presence_indicator, class: 'icon-information'
    end
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
        list_th sortable('categories.name', 'Category')
        list_th sortable('versions.name', 'Target phase')
        list_th sortable('issues.due_date', 'Due date')
        list_th sortable('issues.done', 'Done')
        list_th nil, {class: 'optional-cell'}
        list_th nil, {class: 'optional-cell'}
        list_th nil, {class: 'optional-cell'}

      end
    end
  end

  # Build a toolbox render for issue toolbox.
  # @param [IssueToolbox] issues_toolbox
  def issue_toolbox(issues_toolbox)
    toolbox_tag(IssueToolbox.new(issues_toolbox, @project, User.current))
  end

end
