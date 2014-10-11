class IssueDecorator < ApplicationDecorator
  delegate_all

  # Render document creation info.
  def creation_info
    h.content_tag :div, class: 'creation-info' do
      h.content_tag :p do
        h.content_tag :em do
          h.safe_concat "#{h.t(:label_added)} #{h.distance_of_time_in_words(model.created_at, Time.now)} #{h.t(:label_ago)}, #{h.t(:label_by)} "
          h.safe_concat model.author.decorate.user_link(true)
          h.safe_concat '.'
          h.safe_concat " #{h.t(:label_updated)} #{h.distance_of_time_in_words(model.updated_at, Time.now)} #{h.t(:label_ago)}." unless model.created_at.eql?(model.updated_at)
        end
      end
    end
  end

  # @return [String] tracker name.
  def tracker_str
    model.tracker ? h.resize_text(model.tracker.caption, 15) : '-'
  end

  # @return [String] version name.
  def display_version
    if model.version
      h.content_tag :span, {class: 'info-square'} do
        h.glyph(model.version.caption, 'milestone')
      end
    else
      '-'
    end
  end

  # @return [String] category name.
  def display_category
    if model.category
    h.content_tag :span, {class: 'info-square'} do
      h.glyph(model.category.caption, 'tag')
    end
    else
      '-'
    end
  end

  # @return [String] due date.
  def due_date
    model.due_date ? model.due_date : '-'
  end

  # @return [String] assigned to user name.
  def display_assigned_to
    model.assigned_to ? model.assigned_to.decorate.user_link(true) : '-'
  end

  # @return [String] estimated time.
  def estimated_time
    model.estimated_time ? model.estimated_time : '-'
  end

  # @return [String] start date.
  def start_date
    model.start_date ? model.start_date : '-'
  end

  def display_status
    h.content_tag :span, {class: 'issue-status', style: "background-color: #{model.status.color}"} do
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
        h.safe_concat h.content_tag :span, nil, {class: 'octicon octicon-checklist'}
        h.safe_concat " #{model.count_checked_tasks} of #{model.count_tasks}"
      end
    end
  end
end
