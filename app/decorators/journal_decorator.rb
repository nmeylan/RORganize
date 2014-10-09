class JournalDecorator < ApplicationDecorator
  decorates_association :user
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

  # Render the type of the journalized object.
  def display_object_type
    type = self.journalizable_type
    if type.eql?('Issue') && !self.action_type.eql?(Journal::ACTION_DELETE)
      h.safe_concat h.content_tag :b, "#{self.issue.tracker.caption.downcase} ##{self.issue.id} "
      h.fast_issue_link(self.issue, self.project).html_safe
    elsif type.eql?('Document') && !self.action_type.eql?(Journal::ACTION_DELETE)
      h.fast_document_link(self.document, self.project).html_safe
    else
      h.content_tag :b, "#{type.downcase} #{self.journalizable_identifier}"
    end
  end

  # @return [String] link to model project.
  def project_link
    h.fast_project_link(model.project)
  end

  # @param [Project] project.
  # @return [String] link to project if not nil.
  def display_project_link(project)
    unless project
      h.safe_concat h.content_tag :span, class: 'project', &Proc.new {
        h.safe_concat 'at '
        h.safe_concat project_link
      }
    end
  end

  # @return [String] user avatar image.
  def user_avatar?
    model.user && model.user.avatar
  end

  # Render the details of a journal.
  # @param [Boolean] no_icon if true don't display icon. Otherwise display it.
  def render_details(no_icon = false)
    h.safe_concat h.content_tag :span, self.display_author, class: 'author'
    if model.action_type.eql?(Journal::ACTION_UPDATE) && model.details.to_a.any?
      h.safe_concat h.content_tag :span, nil, class: 'octicon octicon-pencil activity-icon' unless no_icon
      h.content_tag(:ul, (model.details.collect { |detail| h.activity_history_detail_render(detail, self) }).join.html_safe)
    elsif model.action_type.eql?(Journal::ACTION_CREATE)
      h.safe_concat h.content_tag :span, nil, class: 'octicon octicon-plus activity-icon' unless no_icon
      if model.journalizable_type.eql?('Issue')
        h.t(:text_created_this_issue)
      else
        h.t(:text_created_this) + ' ' + model.journalizable_type.downcase
      end
    end
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
