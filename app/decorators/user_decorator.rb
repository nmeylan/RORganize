class UserDecorator < ApplicationDecorator
  delegate_all

  def show_link
    link =  link_to_with_permissions(model.caption , h.user_path(model.slug), nil, nil)
    link ? link : disabled_field(model.caption)
  end

  def sign_in
    model.last_sign_in_at ? model.last_sign_in_at.to_formatted_s(:short) : '-'
  end

  def current_sign_in
    model.current_sign_in_at ? model.current_sign_in_at.to_formatted_s(:short) : '-'
  end

  def display_is_admin
    model.admin.to_s
  end

  def edit_link
    super(h.t(:link_edit), h.edit_user_path(model.slug))
  end

  def delete_link
    super(h.t(:link_delete), h.user_path(model.slug))
  end

  def user_link
    h.link_to model.caption, h.view_profile_path(model.slug)
  end
end
