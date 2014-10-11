class DocumentDecorator < ApplicationDecorator
  delegate_all

  # see #ApplicationDecorator::display_history
  def display_history(journals)
    super(journals)
  end

  # see #ApplicationDecorator::new_link
  def new_link
    super(h.t(:link_new_document), h.new_document_path(context[:project].slug), context[:project])
  end

  # see #ApplicationDecorator::edit_link
  def edit_link
    super(h.t(:link_edit), h.edit_document_path(context[:project].slug, model.id), context[:project])
  end

  # see #ApplicationDecorator::delete_link
  def delete_link
    super(h.t(:link_delete), h.document_path(context[:project].slug, model.id), context[:project])
  end

  # see #ApplicationDecorator::delete_attachment_link
  def delete_attachment_link(attachment)
    super(h.delete_attachment_documents_path(context[:project].slug, attachment.id), context[:project]) if attachment.id
  end

  # see #ApplicationDecorator::download_attachment_link
  def download_attachment_link(attachment)
    super(attachment, h.download_attachment_documents_path(context[:project].slug))
  end

end
