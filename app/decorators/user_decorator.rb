class UserDecorator < ApplicationDecorator
  delegate_all

  def show_link
    link = link_to_with_permissions(model.caption, h.user_path(model.slug), nil, nil)
    link ? link : disabled_field(model.caption)
  end

  def sign_in
    model.last_sign_in_at ? model.last_sign_in_at.to_formatted_s(:long_ordinal) : '-'
  end

  def current_sign_in
    model.current_sign_in_at ? model.current_sign_in_at.to_formatted_s(:long_ordinal) : '-'
  end

  def register_on
    model.created_at.to_formatted_s(:long_ordinal)
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

  def user_link(avatar = true)
    h.content_tag :span, class: 'avatar' do
      h.safe_concat h.image_tag user.avatar.avatar.url(:very_small), {class: 'small_avatar'} if avatar && user.avatar
      h.safe_concat h.link_to model.caption, h.view_profile_path(model.slug), {class: 'author_link'}
    end
  end

  def display_avatar
    h.image_tag user.avatar.avatar.url(:thumb), {class: 'user_profile avatar'} if avatar && user.avatar
  end

  def display_projects
    h.projects(self)
  end

  def role_render
    h.content_tag :span, class: 'role' do

    end
  end

end
