class DocumentDecorator < ApplicationDecorator
  delegate_all

  def creation_info
    "#{h.t(:label_added)} #{h.distance_of_time_in_words(model.created_at, Time.now)} #{h.t(:label_ago)}, #{h.t(:label_by)} #{model.creation_info.user.name}. #{(model.created_at.eql?(model.updated_at) ? '' : "#{h.t(:label_updated)} #{h.distance_of_time_in_words(model.updated_at, Time.now)} #{h.t(:label_ago)}.").to_s}"
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

  def category
    model.category ? model.category.name : '-'
  end

  def version
    model.version ? model.version.name : '-'
  end

  def new_link
    super(h.t(:link_new_document), h.new_document_path(model.project.slug), model.project)
  end

  def edit_link
    super(h.t(:link_edit_document), h.edit_document_path(model.project.slug, model.id), model.project)
  end

  def delete_link
    super(h.t(:link_delete), h.document_path(model.project.slug, model.id), model.project)
  end

end
