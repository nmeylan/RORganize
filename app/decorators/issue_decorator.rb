class IssueDecorator < ApplicationDecorator
  delegate_all

  def creation_info(journals)
    "#{h.t(:label_added)} #{h.distance_of_time_in_words(model.created_at, Time.now)} #{h.t(:label_ago)}, #{h.t(:label_by)} #{journals.first.user.name}. #{(model.created_at.eql?(model.updated_at) ? '' : "#{h.t(:label_updated)} #{h.distance_of_time_in_words(model.updated_at, Time.now)} #{h.t(:label_ago)}.").to_s}"
  end

  def tracker
    model.tracker ? model.tracker.caption : '-'
  end

  def version
    model.version ? model.version.caption : '-'
  end

  def category
    model.category ? model.category.caption : '-'
  end

  def due_date
    model.due_date ? model.due_date : '-'
  end

  def assigned_to
    model.assigned_to ? model.assigned_to.caption : '-'
  end

  def estimated_time
    model.estimated_time ? model.estimated_time : '-'
  end

  def start_date
    model.start_date ? model.start_date : '-'
  end

  def new_link
    super(h.t(:link_new_issue), h.new_issue_path(context[:project].slug), context[:project])
  end

  def edit_link
    super(h.t(:link_edit), h.edit_issue_path(context[:project].slug, model.id), context[:project], model.author_id)
  end

  def start_today_link
    link_to_with_permissions h.glyph(h.t(:link_start_today), 'today'), h.start_today_issues_path(context[:project].slug, model.id), context[:project], nil, {:id => 'start_today', :data => {:confirm => h.t(:text_set_start_date_today)}, :method => :post, :remote => true}
  end

  def update_link
    h.link_to h.glyph(h.t(:link_update), 'comment'), '#update_issue', {:class => 'icon icon-update_issue', :id => 'update_issue_link'}
  end

  def checklist_link
    link_to_with_permissions(h.glyph(h.t(:link_checklist), 'checklist'), h.checklist_issues_path(context[:project].slug), context[:project], nil, {:class => 'open_checklist_overlay'})
  end

  def log_time_link
    h.link_to h.glyph(h.t(:link_log_time), 'clock'), h.fill_overlay_time_entries_path(model.id), {:id => 'log_time'}
  end

  def delete_link
    super(h.t(:link_delete), h.issue_path(context[:project].slug, model.id), context[:project])
  end

  def link_checklist_overlay
    h.link_to h.glyph('', 'checklist'), h.show_checklist_items_issues_path(context[:project].slug, model.id), {:remote => true} if model.checklist_items.to_a.any?
  end


  def attachment_presence_indicator
    h.content_tag :span, nil, {class: 'octicon octicon-attachment'} unless model.attachments.empty?
  end

  def delete_attachment_link(attachment)
    super(h.delete_attachment_issues_path(context[:project].slug,attachment.id), context[:project])
  end
  def download_attachment_link(attachment)
    super(attachment, h.download_attachment_issues_path(context[:project].slug))
  end
end
