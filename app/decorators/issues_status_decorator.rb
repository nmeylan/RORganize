class IssuesStatusDecorator < ApplicationDecorator
  delegate_all

  def dec_position_link(collection_size)
    super(collection_size, h.change_position_issues_statuses_path)
  end

  def inc_position_link
    super(h.change_position_issues_statuses_path)
  end

  def delete_link
    super(h.t(:link_delete), h.issues_status_path(model.id))
  end

  def edit_link
    link = link_to_with_permissions(model.caption, h.edit_issues_status_path(model.id), nil, nil)
    link ? link : disabled_field(model.name)
  end
end
