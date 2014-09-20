# Author: Nicolas Meylan
# Date: 12.09.14
# Encoding: UTF-8
# File: notifications_manager.rb
module Rorganize
  module NotificationsManager
    extend ActiveSupport::Concern
    included do |base|
      after_create :create_notification
    end

    def create_notification
      if RORganize::Application.config.enable_emails_notifications
        if self.is_a?(Comment) || (self.is_a?(Journal) && !self.action_type.eql?(Journal::ACTION_DELETE))
          notification = NotifiableEvent.new(self)
          if notification.recipients.any?
            send_emails(notification)
            in_app_notification(notification)
          end
          notification
        end
      end
    end

    def send_emails(notification)
      if notification.notification_type.eql?(NotifiableEvent::GENERIC_NOTIFICATION)
        NotificationMailer.delay.notification_email(notification)
      elsif notification.notification_type.eql?(NotifiableEvent::MEMBER_NOTIFICATION)
        NotificationMailer.delay.welcome_new_member_email(notification)
        NotificationMailer.delay.member_join_email(notification)
      end
    end

    def in_app_notification(notification)
      if notification.notification_type.eql?(NotifiableEvent::GENERIC_NOTIFICATION)
        Notification.transaction do
          notification.recipients.each do |user|
            Notification.create({notifiable_id: notification.model.id,
                                 notifiable_type: notification.model.class,
                                 notification_type: notification.trigger.class,
                                 user_id: user.id,
                                 from_id: notification.trigger.user_id,
                                 project_id: notification.project.id})
          end
        end
      end
    end


    class NotifiableEvent
      MEMBER_NOTIFICATION = 'MEMBER'
      GENERIC_NOTIFICATION = 'GENERIC'
      attr_reader :recipients, :project, :trigger, :model, :model_url, :notification_type

      def initialize(trigger)
        @trigger = trigger
        @notification_type = GENERIC_NOTIFICATION
        if @trigger.project
          if trigger.is_a? Journal
            @model = trigger.journalizable
            @type = trigger.action_type
          elsif trigger.is_a? Comment
            @model = trigger.commentable
            @type = Journal::ACTION_CREATE
          end
          @date = trigger.created_at
          @project = trigger.project
          @model_url = model_url if @model
          if @model.is_a?(Member)
            @notification_type = MEMBER_NOTIFICATION
            @recipients = member_addition_recipient.compact
          else
            @recipients = find_recipients.compact
          end

        else
          @recipients = []
        end
      end

      def member_addition_recipient
        watchers = []
        watchers |= @model.real_watchers.collect { |watcher| watcher.author } if @model.respond_to?(:real_watchers)
        user = @model.user
        [user, watchers]
      end

      def find_recipients
        participants = []
        watchers = []
        model_author = nil
        model_assigned_to = nil
        mentioned_slugs = []
        if @model
          if @trigger.is_a?(Journal)
            model_author = @model.author if @model.respond_to?(:author) && !@model.author.eql?(User.current)
            model_assigned_to = @model.assigned_to if @model.respond_to?(:assigned_to) && !@model.assigned_to.eql?(User.current)
            mentioned_slugs |= @model.description.scan(/@[^\s]+/) if @model.respond_to?(:description)
          elsif @trigger.is_a? Comment
            mentioned_slugs |= @trigger.content.scan(/@[^\s]+/)
            participants |= @trigger.thread.collect { |comment| comment.author }
          end
          participants << model_author
          participants << model_assigned_to
          mentioned_slugs = mentioned_slugs.map { |slug| slug.gsub(/@/, '') unless slug.eql?(User.current.slug) }
          participants |= User.where(slug: mentioned_slugs) if mentioned_slugs.any?
        end
        watchers |= @model.real_watchers.collect { |watcher| watcher.author } if @model.respond_to?(:real_watchers)
        participants | watchers
      end

      def model_url
        controller = nil
        action = 'show'
        case @model.class.to_s
          when 'Issue'
            controller = 'issues'
          when 'Document'
            controller = 'documents'
          when 'WikiPage'
            controller = 'wiki_pages'
        end
        {controller: controller, action: action, project_id: @project.slug}
      end
    end
  end
end