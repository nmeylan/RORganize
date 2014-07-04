class DocumentDecorator < ApplicationDecorator
  delegate_all

  def creation_info(journals)
    "#{h.t(:label_added)} #{h.distance_of_time_in_words(model.created_at, Time.now)} #{h.t(:label_ago)}, #{h.t(:label_by)} #{journals.first.user.name}. #{(model.created_at.eql?(model.updated_at) ? '' : "#{h.t(:label_updated)} #{h.distance_of_time_in_words(model.updated_at, Time.now)} #{h.t(:label_ago)}.").to_s}"
  end

  def display_description
    if model.description.eql?('')
      '-'
    else
      super do
        model.description
      end
    end
  end


  def display_history(journals)
   super(journals)
  end

  def category
    model.category ? model.category.name : '-'
  end

  def version
    model.version ? model.version.name : '-'
  end

  def new_link
    super(h.t(:link_new_document), h.new_document_path(context[:project].slug), context[:project])
  end

  def edit_link
    super(h.t(:link_edit), h.edit_document_path(context[:project].slug, model.id), context[:project])
  end

  def delete_link
    super(h.t(:link_delete), h.document_path(context[:project].slug, model.id), context[:project])
  end

  def delete_attachment_link(attachment)
    super(h.delete_attachment_documents_path(context[:project].slug,attachment.id), context[:project])
  end

  def download_attachment_link(attachment)
    super(attachment, h.download_attachment_documents_path(context[:project].slug))
  end

end
