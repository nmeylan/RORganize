class JournalDecorator < ApplicationDecorator
  decorates_association :user
  delegate_all

  #Give journal action type
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
    type = self.journalized_type
    if type.eql?('Issue') && !self.action_type.eql?(Journal::ACTION_DELETE)
      h.safe_concat h.content_tag :b, "#{self.issue.tracker.caption.downcase} "
      h.link_to self.issue.caption, h.issue_path(self.project.slug, self.journalized_id)
    else
      h.content_tag :b, "#{type.downcase} #{self.journalized_identifier}"
    end
  end

  def display_action_type_icon
    if self.action_type.eql?(Journal::ACTION_CREATE)
      'octicon octicon-plus'
    elsif self.action_type.eql?(Journal::ACTION_UPDATE)
      'octicon octicon-pencil'
    elsif self.action_type.eql?(Journal::ACTION_DELETE)
      'octicon octicon-trashcan'
    end
  end

  def display_creation_at
    model.created_at.strftime("%I:%M%p")
  end

  def created_at
    model.created_at
  end

  def display_author
    self.user.user_link
  end


end
