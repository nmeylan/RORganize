class NotificationDecorator < ApplicationDecorator
  decorates_association :from
  delegate_all

  def link_to_notifiable
    icon = notification_type_icon
    h.link_to h.glyph(model.notifiable.caption, icon), h.notification_path(model.id), {method: :delete}
  end

  def notification_info
    str = ''
    if model.notification_type.eql?('Journal')
      str += h.t(:label_updated)
    elsif model.notification_type.eql?('Comment')
      str += h.t(:label_commented)
    end
    str +=" #{h.distance_of_time_in_words(model.created_at, Time.now)} #{h.t(:label_ago)}"
    str += " #{h.t(:label_by)} "

  end

  def notification_type_icon
    if model.notification_type.eql?('Journal')
      if model.notifiable.is_a? Issue
        'issue-opened'
      elsif model.notifiable.is_a? Document
        'file-text'
      elsif model.notifiable.is_a? WikiPage
        'wiki'
      end
    elsif model.notification_type.eql?('Comment')
      'comment'
    end
  end

end
