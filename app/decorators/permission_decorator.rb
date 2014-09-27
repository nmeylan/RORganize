class PermissionDecorator < ApplicationDecorator
  delegate_all

  # see #ApplicationDecorator::edit_link.
  def edit_link
    h.link_to(model.caption, h.edit_permission_path(permission.id))
  end

  # see #ApplicationDecorator::delete_link.
  def delete_link
    if User.current.allowed_to?('destroy', 'Permissions')
      if model.is_locked
        h.safe_concat h.content_tag :span, nil, class: 'octicon octicon-lock'
        h.content_tag :span, h.t(:link_delete)
      else
        super h.t(:link_delete), h.permission_path(model.id)
      end
     end
  end
end
