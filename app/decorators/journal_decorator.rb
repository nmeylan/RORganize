class JournalDecorator < ApplicationDecorator
  delegate_all

  #Give journal action type
  def journal_action_type
    if self.action_type.eql?(Journal::ACTION_CREATE)
      h.t(:label_created_lower_case)
    elsif action_type.eql?(Journal::ACTION_UPDATE)
      h.t(:label_updated_lower_case)
    elsif action_type.eql?(Journal::ACTION_DELETE)
      h.t(:label_deleted_lower_case)
    end
  end

  def created_at
    model.created_at
  end




end
