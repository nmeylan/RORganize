class IssuesStatusDecorator < ApplicationDecorator
  delegate_all

  # see #ApplicationDecorator::dec_position_link.
  def dec_position_link(collection_size)
    super(collection_size, h.change_position_issues_statuses_path)
  end

  # see #ApplicationDecorator::inc_position_link.
  def inc_position_link
    super(h.change_position_issues_statuses_path)
  end

  # see #ApplicationDecorator::delete_link.
  def delete_link
    super(h.t(:link_delete), h.issues_status_path(model))
  end

  # see #ApplicationDecorator::edit_link.
  def edit_link
    link = link_to_with_permissions(model.caption, h.edit_issues_status_path(model), nil, nil)
    link ? link : disabled_field(model.caption)
  end
end
