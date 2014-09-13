class NotificationMailer < ActionMailer::Base
  helper ApplicationHelper
  helper JournalsHelper
  layout 'mail'

  def notification_email(notification)
    @notification = notification
    subject = "RORganize - [#{notification.project.slug}] [#{notification.model.class.to_s} ##{notification.model.id}] : #{notification.model.caption}"
    mail(bcc: notification.recipients.map { |recipient| recipient.email }, subject: subject, from: 'RORganize Notifier') do |format|
      if @notification.trigger.is_a? Journal
        format.html { render file: 'notification_mailer/journal_email' }
        format.text { render file: 'notification_mailer/journal_email' }
      elsif @notification.trigger.is_a? Comment
      format.html { render file: 'notification_mailer/comment_email' }
        format.text { render file: 'notification_mailer/comment_email' }
      end
    end
  end

  def welcome_new_member_email(notification)
    @notification = notification
    subject = "RORganize - [#{notification.project.slug}] : Welcome to the project!"
    mail(bcc: notification.recipients[0].email, subject: subject, from: 'RORganize Notifier')
  end

  def member_join_email(notification)
    @notification = notification
    subject = "RORganize - [#{notification.project.slug}] : A new member join the project!"
    mail(bcc: notification.recipients[1].collect { |recipient| recipient.email }, subject: subject, from: 'RORganize Notifier')
  end
end
