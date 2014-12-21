class IssueDecorator < ApplicationDecorator
  decorates_association :assigned_to
  delegate_all

  # @return [String] tracker name.
  def tracker_str
    model.tracker ? h.resize_text(model.tracker.caption, 15) : '-'
  end

  def activity_issue_caption
    h.concat h.content_tag :b, "#{model.tracker.caption.downcase} ##{self.issue.id} "
  end

  def display_object_type(project)
    h.concat h.content_tag :b, "#{h.t(:label_issue).downcase} ##{self.id} "
    h.fast_issue_link(model, project).html_safe
  end

  # @return [String] due date.
  def display_due_date
    model.due_date ? model.due_date.strftime(Rorganize::DATE_FORMAT_Y) : '-'
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
  def estimated_time
    model.estimated_time ? model.estimated_time : '-'
  end

  # @return [String] start date.
  def display_start_date
    model.start_date ? model.start_date.strftime(Rorganize::DATE_FORMAT_Y) : '-'
  end

  def display_updated_at
    model.updated_at.strftime(Rorganize::TIME_FORMAT_Y)
  end

  def display_status
    h.content_tag :span, {class: 'issue-status', style: "#{h.style_background_color(model.status.color)}"} do
      model.status.caption
    end
  end

  def display_done_progression(css_class = nil)
    h.mini_progress_bar_tag(model.done, css_class)
  end
  # see #ApplicationDecorator::new_link.
  def new_link
    super(h.t(:link_new_issue), h.new_issue_path(context[:project].slug), context[:project])
  end

  # see #ApplicationDecorator::edit_link.
  def edit_link
    super(h.t(:link_edit), h.edit_issue_path(context[:project].slug, model.id), context[:project], model.author_id)
  end

  def show_link
    super(h.issue_path(context[:project].slug, model.id), context[:project])
  end

  # @return [String] link to start today action (if user has the permission).
  def start_today_link
    link_to_with_permissions h.glyph(h.t(:link_start_today), 'today'), h.start_today_issues_path(context[:project].slug, model.id), context[:project], nil, {id: 'start-today', data: {confirm: h.t(:text_set_start_date_today)}, method: :post, remote: true}
  end

  # @return [String] link to log time action.
  def log_time_link
    if User.current.allowed_to?('new', 'time_entries', context[:project])
      h.link_to h.glyph(h.t(:link_log_time), 'clock'), h.fill_overlay_time_entries_path(model.id), {id: 'log-time', class: 'button'}
    end
  end

  # see #ApplicationDecorator::delete_link
  def delete_link
    super(h.t(:link_delete), h.issue_path(context[:project].slug, model.id), context[:project], model.author_id)
  end

  # see #ApplicationDecorator::delete_attachment_link
  def delete_attachment_link(attachment)
    super(h.delete_attachment_issues_path(context[:project].slug, attachment.id), context[:project])
  end

  # see #ApplicationDecorator::download_attachment_link
  def download_attachment_link(attachment)
    super(attachment)
  end

  def checklist_progression
    if model.has_task_list?
      h.content_tag :span do
        h.concat h.content_tag :span, nil, {class: 'octicon octicon-checklist'}
        h.concat " #{model.count_checked_tasks} of #{model.count_tasks}"
      end
    end
  end
end
