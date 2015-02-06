class JournalDecorator < ApplicationDecorator
  decorates_association :user
  decorates_association :journalizable
  delegate_all

  # @return [String] type of the journal.
  def display_action_type
    if self.action_type.eql?(Journal::ACTION_CREATE)
      h.t(:label_created_lower_case)
    elsif self.action_type.eql?(Journal::ACTION_UPDATE)
      h.t(:label_updated_lower_case)
    elsif self.action_type.eql?(Journal::ACTION_DELETE)
      h.t(:label_deleted_lower_case)
    end
  end

  # Render the type of the journalizable object.
  def display_object_type
    if self.journalizable && self.journalizable.respond_to?(:display_object_type)
      self.journalizable.display_object_type(self.project)
    else
      h.content_tag :b, "#{model.journalizable_type.downcase} #{model.journalizable_identifier}"
    end
  end

  # @return [String] link to model project.
  def project_link
    h.fast_project_link(model.project)
  end

  # @return [String] user avatar image.
  def user_avatar?
    model.user && model.user.avatar
  end

  # Render the details of a journal.
  # @param [Boolean] no_icon if true don't display icon. Otherwise display it.
  def render_details(no_icon = false)
    h.concat_span_tag self.display_author, class: 'author'
    if render_update_detail?
      render_update_details(no_icon)
    elsif render_create_detail?
      render_create_details(no_icon)
    end
  end

  def render_create_details(no_icon)
    h.concat_span_tag nil, class: 'octicon octicon-plus activity-icon' unless no_icon
    if model.journalizable_type.eql?('Issue')
      h.t(:text_created_this_issue)
    else
      h.t(:text_created_this) + ' ' + model.journalizable_type.downcase
    end
  end

  def render_update_details(no_icon)
    h.concat_span_tag nil, class: 'octicon octicon-pencil activity-icon' unless no_icon
    h.content_tag(:ul, (model.details.collect { |detail| h.activity_history_detail_render(detail, self) }).join.html_safe)
  end

  def render_create_detail?
    model.action_type.eql?(Journal::ACTION_CREATE)
  end

  def render_update_detail?
    model.action_type.eql?(Journal::ACTION_UPDATE) && model.details.to_a.any?
  end

  # @return [String] the icon of the journal type.
  def display_action_type_icon
    if self.action_type.eql?(Journal::ACTION_CREATE)
      'octicon octicon-plus activity-icon'
    elsif self.action_type.eql?(Journal::ACTION_UPDATE)
      'octicon octicon-pencil activity-icon'
    elsif self.action_type.eql?(Journal::ACTION_DELETE)
      'octicon octicon-trashcan activity-icon'
    end
  end

  # @return [String] formatted date.
  def display_creation_at
    model.created_at.strftime('%I:%M%p')
  end

  # Render the a link to the user.
  # @param [Boolean] avatar if true display avatar, else hide it.
  def display_author(avatar = true)
    self.user ? self.user.user_link(avatar) : h.t(:label_unknown)
  end

  # Render the user avatar.
  def display_author_avatar
    user_avatar? ? h.image_tag(self.user.avatar.avatar.url(:thumb), {class: 'avatar'}) : ''
  end
end
