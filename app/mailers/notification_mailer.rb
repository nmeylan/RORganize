class NotificationMailer < ActionMailer::Base
  helper ApplicationHelper
  helper JournalsHelper
  layout 'mail'

  def notification_email(notification)
    @notification = notification
    mail(bcc: notification.recipients.map { |recipient| recipient.email }, subject: "RORganize - [#{notification.project.slug}] [#{notification.model.class.to_s} ##{notification.model.id}] : #{notification.model.caption}") do |format|
      if @notification.trigger.is_a? Journal
        format.html { render file: 'notification_mailer/journal_email' }
        format.text { render file: 'notification_mailer/journal_email' }
      elsif @notification.trigger.is_a? Comment
      format.html { render file: 'notification_mailer/comment_email' }
        format.text { render file: 'notification_mailer/comment_email' }
      end
    end
  end
end
