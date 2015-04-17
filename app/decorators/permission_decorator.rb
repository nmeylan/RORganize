class PermissionDecorator < ApplicationDecorator
  delegate_all

  # see #ApplicationDecorator::edit_link.
  def edit_link
    if User.current.allowed_to?('edit', 'permissions')
      h.link_to(model.caption, h.edit_permission_path(permission))
    else
      model.caption
    end
  end

  # see #ApplicationDecorator::delete_link.
  def delete_link
    if User.current.allowed_to?('destroy', 'Permissions')
      if model.is_locked
        h.concat h.content_tag :span, nil, class: 'octicon octicon-lock'
        h.content_tag :span, h.t(:link_delete)
      else
        super h.t(:link_delete), h.permission_path(model)
      end
    end
  end
end
