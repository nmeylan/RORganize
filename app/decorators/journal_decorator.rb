class JournalDecorator < ApplicationDecorator
  decorates_association :user
  delegate_all

  #Give journalizable action type
  def display_action_type
    if self.action_type.eql?(Journal::ACTION_CREATE)
      h.t(:label_created_lower_case)
    elsif self.action_type.eql?(Journal::ACTION_UPDATE)
      h.t(:label_updated_lower_case)
    elsif self.action_type.eql?(Journal::ACTION_DELETE)
      h.t(:label_deleted_lower_case)
    end
  end

  def display_object_type
    type = self.journalizable_type
    if type.eql?('Issue') && !self.action_type.eql?(Journal::ACTION_DELETE)
      h.safe_concat h.content_tag :b, "#{self.issue.tracker.caption.downcase} ##{self.issue.id} "
      h.link_to self.issue.caption, h.issue_path(self.project.slug, self.journalizable_id)
    else
      h.content_tag :b, "#{type.downcase} #{self.journalizable_identifier}"
    end
  end

  def project_link
    h.link_to model.project.caption, h.overview_projects_path(model.project.slug)
  end

  def display_project_link(project)
    unless project
      h.safe_concat h.content_tag :span, class: 'object_type', &Proc.new{
        h.safe_concat 'on '
        h.safe_concat project_link
      }
    end
  end

  def user_avatar?
    model.user && model.user.avatar
  end

  def render_details(no_icon = false)
    h.safe_concat h.content_tag :span, self.display_author, class: 'author'
    if model.action_type.eql?(Journal::ACTION_UPDATE) && model.details.to_a.any?
      h.safe_concat h.content_tag :span, nil, class: "octicon octicon-pencil activity_icon" unless no_icon
      h.content_tag(:ul, (model.details.collect { |detail| h.activity_history_detail_render(detail) }).join.html_safe)
    elsif model.action_type.eql?(Journal::ACTION_CREATE)
      h.safe_concat h.content_tag :span, nil, class: "octicon octicon-plus activity_icon" unless no_icon
      if model.journalizable_type.eql?('Issue')
        h.t(:text_created_this_issue)
      else
        h.t(:text_created_this) + ' ' + model.journalizable_type.downcase
      end
    end
  end

  def display_action_type_icon
    if self.action_type.eql?(Journal::ACTION_CREATE)
      'octicon octicon-plus activity_icon'
    elsif self.action_type.eql?(Journal::ACTION_UPDATE)
      'octicon octicon-pencil activity_icon'
    elsif self.action_type.eql?(Journal::ACTION_DELETE)
      'octicon octicon-trashcan activity_icon'
    end
  end

  def display_creation_at
    model.created_at.strftime("%I:%M%p")
  end

  def created_at
    model.created_at
  end

  def display_author(avatar = true)
    self.user ? self.user.user_link(avatar) : h.t(:label_unknown)
  end

  def display_author_avatar
    user_avatar? ? h.image_tag(self.user.avatar.avatar.url(:thumb), {class: 'avatar'}) : ''
  end


end
