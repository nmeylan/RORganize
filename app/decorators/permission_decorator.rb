class PermissionDecorator < ApplicationDecorator
  delegate_all

  def edit_link
    h.link_to(model.caption, h.edit_permission_path(permission.id))
  end

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

  def is_critical?
    critical_permissions = %w(destroy delete remove public)
    critical_permissions.include?(model.action.downcase)
  end
end
