class QueryDecorator < ApplicationDecorator
  delegate_all

  def edit_link
    super(h.t(:link_edit), h.edit_query_path(model.id))
  end

  def delete_link
    super(h.t(:link_delete), h.query_path(model.id))
  end

  def show_link
    link = link_to_with_permissions(model.caption, h.query_path(model.id), nil, nil)
    link ? link : model.caption
  end
end
