class NotificationDecorator < ApplicationDecorator
  decorates_association :from
  delegate_all

  def link_to_notifiable
    icon = notification_type_icon
    caption = resize_text(model.notifiable.caption, 80)
    caption = model.notifiable_type.eql?('Issue') ? "##{model.notifiable_id} : #{caption}" : caption
    h.link_to h.glyph(caption, icon), h.notification_path(model.id), {method: :delete}
  end

  def notification_info
    str = ''
    if model.trigger_type.eql?('Journal')
      str += h.t(:label_updated)
    elsif model.trigger_type.eql?('Comment')
      str += h.t(:label_commented)
    end
    str +=" #{h.distance_of_time_in_words(model.created_at, Time.now)} #{h.t(:label_ago)}"
    str += " #{h.t(:label_by)} "
  end

  def recipient_type
    if model.recipient_type.eql?(Notification::RECIPIENT_TYPE_WATCHER)
      icon = 'eye'
      label = h.t(:text_notification_recipient_type_watcher)
    else
      icon = 'person'
      label = h.t(:text_notification_recipient_type_participant)
    end
    h.content_tag :span, h.content_tag(:span, nil, {class: "octicon octicon-#{icon} "}), {class: 'tooltipped tooltipped-s notification-recipient-type', label: label}
  end

  def notification_type_icon
    if true || model.trigger_type.eql?('Journal')
      if model.notifiable.is_a? Issue
        'issue-opened'
      elsif model.notifiable.is_a? Document
        'file-text'
      elsif model.notifiable.is_a? WikiPage
        'wiki'
      end
    elsif model.trigger_type.eql?('Comment')
      'comment'
    end
  end

end
