class DocumentDecorator < ApplicationDecorator
  delegate_all

  # see #ApplicationDecorator::display_history
  def display_history(history)
    super(history)
  end

  # see #ApplicationDecorator::new_link
  def new_link
    super(h.t(:link_new_document), h.new_document_path(context[:project].slug), context[:project])
  end

  # see #ApplicationDecorator::edit_link
  def edit_link
    super(h.t(:link_edit), h.edit_document_path(context[:project].slug, model), context[:project])
  end

  # see #ApplicationDecorator::delete_link
  def delete_link
    super(h.t(:link_delete), h.document_path(context[:project].slug, model), context[:project])
  end

  # see #ApplicationDecorator::delete_attachment_link
  def delete_attachment_link(attachment)
    super(h.delete_attachment_documents_path(context[:project].slug, attachment), context[:project]) if attachment.id
  end

  def display_object_type(project)
    h.concat h.content_tag :b, "#{h.t(:label_document).downcase} "
    h.fast_document_link(self, project).html_safe
  end

  def user_allowed_to_edit?
   User.current.allowed_to?('edit', 'documents', project)
  end
end
