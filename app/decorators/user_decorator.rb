class UserDecorator < ApplicationDecorator
  delegate_all

  def show_link
    link = link_to_with_permissions(model.caption, h.user_path(model.slug), nil, nil)
    link ? link : disabled_field(model.caption)
  end

  # @return [String] formatted current sign in date.
  def sign_in
    model.last_sign_in_at ? model.last_sign_in_at.to_formatted_s(:long_ordinal) : '-'
  end

  # @return [String] formatted current sign in date.
  def current_sign_in
    model.current_sign_in_at ? model.current_sign_in_at.to_formatted_s(:long_ordinal) : '-'
  end

  # @return [String] formatted registration date.
  def register_on
    model.created_at.to_formatted_s(:long_ordinal)
  end

  # @return [String] is user admin.
  def display_is_admin
    model.admin.to_s
  end

  # see #ApplicationDecorator::edit_link.
  def edit_link
    super(h.t(:link_edit), h.edit_user_path(model.slug))
  end

  # see #ApplicationDecorator::delete_link.
  def delete_link
    super(h.t(:link_delete), h.user_path(model.slug))
  end

  # Render a link to the user profile.
  # @param [Boolean] avatar : if true display user avatar, else hide it.
  def user_link(avatar = true)
    h.content_tag :span, class: 'avatar' do
      h.safe_concat h.image_tag model.avatar.avatar.url(:very_small), {class: 'small_avatar'} if avatar && model.avatar
      h.safe_concat h.fast_profile_link(model)
    end
  end

  # Render user avatar.
  def display_avatar
    h.image_tag user.avatar.avatar.url(:thumb), {class: 'user_profile avatar'} if avatar && user.avatar
  end

  # Display user projects.
  def display_projects
    h.projects(self)
  end

  # Display user roles on all its projects.
  def role_render
    h.content_tag :span, class: 'role' do

    end
  end

end
