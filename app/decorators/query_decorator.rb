class QueryDecorator < ApplicationDecorator
  delegate_all

  # see #ApplicationDecorator::edit_link.
  def edit_link
    super(h.t(:link_edit), h.edit_query_path(model.id))
  end

  # see #ApplicationDecorator::delete_link.
  def delete_link
    super(h.t(:link_delete), h.query_path(model.id))
  end

  #Render a link to show action.
  def show_link
    link = link_to_with_permissions(model.caption, h.query_path(model.id), nil, nil)
    link ? link : model.caption
  end

  # @return [String] author name.
  def author
    model.user.caption
  end

end
