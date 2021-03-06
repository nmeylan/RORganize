class NotificationDecorator < ApplicationDecorator
  decorates_association :from
  delegate_all

  def link_to_notifiable
    icon = model.notifiable_type.downcase
    caption = h.resize_text(model.notifiable.caption, 80)
    caption = model.notifiable_type.eql?('Issue') ? "##{model.notifiable.sequence_id} : #{caption}" : caption
    h.link_to h.glyph(caption, icon), h.notification_path(model), {method: :delete, class: "notification-link #{'viewed' if model.deleted_at?}"}
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
    h.content_tag :span, h.content_tag(:span, nil, {class: "octicon octicon-#{icon} "}), {class: 'tooltipped tooltipped-w notification-recipient-type', label: label}
  end

end
