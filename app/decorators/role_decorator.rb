class RoleDecorator < ApplicationDecorator
  delegate_all

  # see #ApplicationDecorator::edit_link.
  def edit_link
    options = model.is_locked ? {class: 'default-role'} : {}
    link = link_to_with_permissions(model.caption, h.edit_role_path(model.id), nil, nil, options)
    link ? link : disabled_field(model.caption)
  end

  # see #ApplicationDecorator::delete_link.
  def delete_link
    super(h.t(:link_delete), h.role_path(model.id)) unless model.is_locked
  end

end
