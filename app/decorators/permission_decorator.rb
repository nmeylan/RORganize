class PermissionDecorator < ApplicationDecorator
  delegate_all

  # see #ApplicationDecorator::edit_link.
  def edit_link
    h.link_to(model.caption, h.edit_permission_path(permission.id))
  end

  # see #ApplicationDecorator::delete_link.
  def delete_link
    if User.current.allowed_to?('destroy', 'Permissions')
      unless model.is_locked
        super h.t(:link_delete), h.permission_path(model.id)
      else
        h.safe_concat h.content_tag :span, nil, class: 'octicon octicon-lock'
        h.content_tag :span, h.t(:link_delete)
       end
     end
  end
end
