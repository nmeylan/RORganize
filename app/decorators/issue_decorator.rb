class IssueDecorator < ApplicationDecorator
  decorates_association :assigned_to
  delegate_all
  # see #ApplicationDecorator::new_link.
  def new_link
    super(h.t(:link_new_issue), h.new_project_issue_path(context[:project].slug), context[:project])
  end

  # see #ApplicationDecorator::edit_link.
  def edit_link
    super(h.t(:link_edit), h.edit_project_issue_path(context[:project].slug, model), context[:project], model.author_id)
  end

  def show_link
    super(h.project_issue_path(context[:project].slug, model), context[:project])
  end

  # @return [String] link to log time action.
  def log_time_link
    if User.current.allowed_to?('new', 'time_entries', context[:project])
      h.link_to h.glyph(h.t(:link_log_time), 'clock'), h.fill_overlay_time_entries_path(model), {id: 'log-time', class: 'btn btn-primary'}
    end
  end

  # see #ApplicationDecorator::delete_link
  def delete_link
    super(h.t(:link_delete), h.project_issue_path(context[:project].slug, model), context[:project], model.author_id)
  end

  # see #ApplicationDecorator::delete_attachment_link
  def delete_attachment_link(attachment)
    super(h.delete_attachment_project_issues_path(context[:project].slug, attachment), context[:project])
  end

  # @return [String] tracker name.
  def tracker_str
    model.tracker ? h.resize_text(model.tracker.caption, 15) : '-'
  end

  def activity_issue_caption
    h.concat h.content_tag :b, "#{model.tracker.caption.downcase} ##{self.issue.sequence_id} "
  end

  def display_object_type(project)
    h.concat h.content_tag :b, "#{h.t(:label_issue).downcase} ##{self.sequence_id} "
    h.fast_issue_link(model, project).html_safe
  end

  # @return [String] due date.
  def display_due_date
    model.due_date ? model.due_date.strftime(Rorganize::DATE_FORMAT_Y) : '-'
  end

  # @return [String] start date.
  def display_start_date
    model.start_date ? model.start_date.strftime(Rorganize::DATE_FORMAT_Y) : '-'
  end

  # @return [String] assigned to user name.
  def display_assigned_to
    model.assigned_to ? self.assigned_to.user_link(true) : '-'
  end

  def display_assigned_to_avatar(format = :thumb)
    if model.assigned_to
      self.assigned_to.user_avatar_link(h.t(:field_assigned_to), format)
    end
  end

  # @return [String] estimated time.
  def display_estimated_time
    model.estimated_time ? model.estimated_time : '-'
  end

  def display_updated_at
    model.updated_at.strftime(Rorganize::TIME_FORMAT_Y)
  end

  def display_status
    h.content_tag :span, {class: 'issue-status', style: "#{h.style_background_color(model.status.color)}"} do
      model.status.caption
    end
  end

  def display_done_progression
    h.progress_bar_tag(model.done, true)
  end

  def checklist_progression
    if model.has_task_list?
      h.content_tag :span do
        h.concat h.content_tag :span, nil, {class: 'octicon octicon-checklist'}
        h.concat " #{model.count_checked_tasks} of #{model.count_tasks}"
      end
    end
  end

  def user_allowed_to_edit?
    (model.author_id.eql?(User.current.id) && User.current.allowed_to?('edit', 'issues', project)) ||
        User.current.allowed_to?('edit_not_owner', 'issues', project)
  end
end
