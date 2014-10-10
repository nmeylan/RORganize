class DocumentDecorator < ApplicationDecorator
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

  # see #ApplicationDecorator::display_history
  def display_history(journals)
    super(journals)
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
