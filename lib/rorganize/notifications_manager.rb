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
          if notification.recipients.any? || notification.recipients_hash.any?
            send_emails(notification)
            in_app_notification(notification)
          end
          notification
        end
      end
    end

    def send_emails(notification)
      if notification.notification_type.eql?(NotifiableEvent::GENERIC_NOTIFICATION)
        notification.recipients = real_recipients(notification, 'email').values.flatten
        if notification.recipients.any?
          NotificationMailer.delay.notification_email(notification)
        end
      elsif notification.notification_type.eql?(NotifiableEvent::MEMBER_NOTIFICATION)
        NotificationMailer.delay.welcome_new_member_email(notification)
        NotificationMailer.delay.member_join_email(notification)
      end
    end

    def in_app_notification(notification)
      if notification.notification_type.eql?(NotifiableEvent::GENERIC_NOTIFICATION)
        notification.recipients = notification.recipients_hash.values
        Notification.transaction do
          real_recipients(notification, 'in_app').each do |key, users|
            users.each do |user|
              Notification.create({notifiable_id: notification.model.id,
                                   notifiable_type: notification.model.class,
                                   trigger_type: notification.trigger.class,
                                   trigger_id: notification.trigger.id,
                                   user_id: user.id,
                                   from_id: notification.trigger.user_id,
                                   project_id: notification.project.id})
            end
          end
        end
      end
    end

    def real_recipients(notification, type)
      enumeration_watcher = Enumeration.find_by_name("notification_watcher_#{type}").id
      enumeration_participant = Enumeration.find_by_name("notification_participant_#{type}").id
      tmp_hash = {}
      notification.recipients_hash.each do |key, users|
        tmp_hash[key] = []
        users.each do |user|
          enum_preference_ids = user.preferences.collect { |pref| pref.enumeration_id }
          if key.eql?(:participants) && enum_preference_ids.include?(enumeration_participant) ||
              key.eql?(:watchers) && enum_preference_ids.include?(enumeration_watcher)
            tmp_hash[key] << user
          end
        end
      end
      tmp_hash
    end

    def email_recipiends(notification)

    end

    class NotifiableEvent
      MEMBER_NOTIFICATION = 'MEMBER'
      GENERIC_NOTIFICATION = 'GENERIC'
      attr_accessor :recipients, :recipients_hash
      attr_reader :project, :trigger, :model, :model_url, :notification_type

      def initialize(trigger)
        @trigger = trigger
        @notification_type = GENERIC_NOTIFICATION
        @recipients = []
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
            find_recipients.compact
          end

        else
          @recipients = {}
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
        model_assigned_to = nil
        mentioned_slugs = []
        if @model
          if @trigger.is_a?(Journal)
            model_assigned_to = @model.assigned_to if @model.respond_to?(:assigned_to) && !@model.assigned_to.eql?(User.current)
            mentioned_slugs |= @model.description.scan(/@[^\s]+/) if @model.respond_to?(:description)
          elsif @trigger.is_a? Comment
            mentioned_slugs |= @trigger.content.scan(/@[^\s]+/)
            participants |= @trigger.thread.collect { |comment| comment.author unless comment.eql?(@trigger) }
          end
          participants << model_assigned_to
          mentioned_slugs = mentioned_slugs.map { |slug| slug.gsub(/@/, '') unless slug.eql?(User.current.slug) }
          participants |= User.where(slug: mentioned_slugs).eager_load(:preferences) if mentioned_slugs.any?
        end
        watchers |= @model.real_watchers.collect { |watcher| watcher.author } if @model.respond_to?(:real_watchers)
        @recipients_hash = {}
        @recipients_hash[:participants] = participants.compact
        @recipients_hash[:watchers] = watchers.compact
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