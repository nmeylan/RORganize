class UserDecorator < ApplicationDecorator
  delegate_all

  def show_link
    link = link_to_with_permissions(model.caption, h.user_path(model.slug), nil, nil)
    link ? link : disabled_field(model.caption)
  end

  # see #ApplicationDecorator::edit_link.
  def edit_link
    super(h.t(:link_edit), h.edit_user_path(model.slug))
  end

  # see #ApplicationDecorator::delete_link.
  def delete_link
    super(h.t(:link_delete), h.user_path(model.slug))
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
    content_tag(:span, nil, class: 'medium-octicon octicon-crown')if model.admin
  end

  # Render a link to the user profile.
  # @param [Boolean] avatar : if true display user avatar, else hide it.
  def user_link(avatar = true)
    h.content_tag :span, class: "#{avatar ? 'avatar' : ''}" do
      h.concat h.fast_user_small_avatar(model) if avatar && model.avatar
      h.concat h.fast_profile_link(model)
    end
  end

  def user_avatar_link(text = '', format = :thumb)
    h.link_to self.display_avatar('user-avatar-link', format),
              h.view_profile_path(self.slug),
              {class: 'tooltipped tooltipped-s', label: "#{text} #{self.caption}"}
  end

  # Render user avatar.
  def display_avatar(css_class = '', format = :thumb)
    h.image_tag model.avatar.avatar.url(format), {class: "user-profile avatar #{css_class}"} if model.avatar
  end

  # Display user projects.
  def display_projects
    h.projects(self)
  end
end
