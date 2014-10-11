require 'issues/issue_filter'
require 'issues/issue_toolbox'
module IssuesHelper
  include CommentsHelper
  include Rorganize::Helpers::IssuesHelper

  # Build a json filter form.
  def issues_generics_form_to_json
    issue_filter = IssueFilter.new(@project)
    filter_content_hash = issue_filter.content
    hash_for_radio = filter_content_hash['hash_for_radio']
    hash_for_select = filter_content_hash['hash_for_select']
    form_hash = build_form_hash(hash_for_radio, hash_for_select)
    issue_filter.build_json_form(form_hash)
  end

  def build_form_hash(hash_for_radio, hash_for_select)
    form_hash = {}
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
    form_hash
  end

  # Build a list of issues.
  # @param [Array] collection of issues.
  def list(collection)
    content_tag :table, {class: 'issue list', 'data-link' => toolbox_issues_path(@project.slug)} do
      safe_concat list_header
      safe_concat(list_body(collection))
    end
  end

  def list_body(collection)
    collection.collect do |issue|
      list_row(issue)
    end.join.html_safe
  end

  def list_row(issue)
    content_tag :tr, class: "has-context-menu odd-even issue-tr" do
      safe_concat list_column(check_box_tag("issue-#{issue.id.to_s}", issue.id), class: 'cell-checkbox')
      safe_concat list_column issue.id, class: 'list-center id'
      safe_concat list_column issue.tracker_str, class: 'list-center tracker'
      safe_concat list_column issue.show_link, {class: 'name', id: issue.id}
      safe_concat list_column issue.display_assigned_to, class: 'list-center assigned-to'
      safe_concat list_column issue.display_status, class: 'list-center status'
      safe_concat list_column issue.display_category, class: 'list-center category'
      safe_concat list_column issue.display_version, class: 'list-center version'
      safe_concat list_column issue.due_date, class: 'list-center due-date'
      safe_concat list_column issue.display_done_progression, {class: 'list-center done tooltipped tooltipped-s', label: "#{issue.done}%"}
      safe_concat list_column issue.checklist_progression, class: 'icon-information'
      safe_concat list_column issue.comment_presence_indicator, class: 'icon-information'
      safe_concat list_column issue.attachment_presence_indicator, class: 'icon-information'
    end
  end

  def list_column(content, options = {})
    content_tag :td, content, options
  end

  def list_header
    content_tag :thead do
      content_tag :tr, class: 'header' do
        safe_concat content_tag :th, link_to(glyph('', 'check'), '#', {class: 'icon-checked', id: 'check-all', 'cb_checked' => 'b'})
        safe_concat content_tag :th, sortable('issues.id', '#')
        safe_concat content_tag :th, sortable('trackers.name', 'Tracker')
        safe_concat content_tag :th, sortable('issues.subject', 'Subject'), {class: 'list-left no-padding-left'}
        safe_concat content_tag :th, sortable('users.name', 'Assigned to')
        safe_concat content_tag :th, sortable('issues_statuses.enumeration_id', 'Status')
        safe_concat content_tag :th, sortable('categories.name', 'Category')
        safe_concat content_tag :th, sortable('versions.name', 'Target phase')
        safe_concat content_tag :th, sortable('issues.due_date', 'Due date')
        safe_concat content_tag :th, sortable('issues.done', 'Done')
        safe_concat content_tag :th, nil, {class: 'optional-cell'}
        safe_concat content_tag :th, nil, {class: 'optional-cell'}
        safe_concat content_tag :th, nil, {class: 'optional-cell'}

      end
    end
  end

  # Build a toolbox render for issue toolbox.
  # @param [IssueToolbox] issues_toolbox
  def issue_toolbox(issues_toolbox)
    toolbox_tag(IssueToolbox.new(issues_toolbox, @project, User.current))
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
