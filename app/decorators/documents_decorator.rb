class DocumentsDecorator < ApplicationCollectionDecorator
  delegate :current_page, :per_page, :offset, :total_entries, :total_pages

  def display_collection
    super
  end

  def new_link
    super(h.t(:link_new_document), h.new_document_path(context[:project].slug), context[:project])
  end

end
