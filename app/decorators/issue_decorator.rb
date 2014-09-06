class IssueDecorator < ApplicationDecorator
  delegate_all

  # Render document creation info.
  def creation_info(journals)
    "#{h.t(:label_added)} #{h.distance_of_time_in_words(model.created_at, Time.now)} #{h.t(:label_ago)}, #{h.t(:label_by)} #{model.author.caption}. #{(model.created_at.eql?(model.updated_at) ? '' : "#{h.t(:label_updated)} #{h.distance_of_time_in_words(model.updated_at, Time.now)} #{h.t(:label_ago)}.").to_s}"
  end

  # @return [String] tracker name.
  def tracker
    model.tracker ? model.tracker.caption : '-'
  end

  # @return [String] version name.
  def version_str
    model.version ? model.version.caption : '-'
  end

  # @return [String] category name.
  def category
    model.category ? model.category.caption : '-'
  end

  # @return [String] due date.
  def due_date
    model.due_date ? model.due_date : '-'
  end

  # @return [String] assigned to user name.
  def assigned_to
    model.assigned_to ? model.assigned_to.caption : '-'
  end

  # @return [String] estimated time.
  def estimated_time
    model.estimated_time ? model.estimated_time : '-'
  end

  # @return [String] start date.
  def start_date
    model.start_date ? model.start_date : '-'
  end

  # see #ApplicationDecorator::new_link.
  def new_link
    super(h.t(:link_new_issue), h.new_issue_path(context[:project].slug), context[:project])
  end

  # see #ApplicationDecorator::edit_link.
  def edit_link
    super(h.t(:link_edit), h.edit_issue_path(context[:project].slug, model.id), context[:project], model.author_id)
  end

  # @return [String] link to start today action (if user has the permission).
  def start_today_link
    link_to_with_permissions h.glyph(h.t(:link_start_today), 'today'), h.start_today_issues_path(context[:project].slug, model.id), context[:project], nil, {:id => 'start_today', :data => {:confirm => h.t(:text_set_start_date_today)}, :method => :post, :remote => true}
  end

  # @return [String] link to log time action.
  def log_time_link
    #TODO check permission
    h.link_to h.glyph(h.t(:link_log_time), 'clock'), h.fill_overlay_time_entries_path(model.id), {:id => 'log_time'}
  end

  # see #ApplicationDecorator::delete_link
  def delete_link
    super(h.t(:link_delete), h.issue_path(context[:project].slug, model.id), context[:project], model.author_id)
  end

  # @return [String] an indicator if model has attachments.
  def attachment_presence_indicator
    h.content_tag :span, nil, {class: 'octicon octicon-attachment'} unless model.attachments.empty?
  end

  # see #ApplicationDecorator::delete_attachment_link
  def delete_attachment_link(attachment)
    super(h.delete_attachment_issues_path(context[:project].slug,attachment.id), context[:project])
  end

  # see #ApplicationDecorator::download_attachment_link
  def download_attachment_link(attachment)
    super(attachment)
  end

  def checklist_progression
    if model.has_task_list?
      h.content_tag :span, " #{model.count_checked_tasks} of #{model.count_tasks}", {class: 'octicon octicon-checklist'}
    end
  end
end
