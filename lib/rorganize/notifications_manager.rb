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
            Rorganize::NotificationsManager.send_emails(notification)
            Rorganize::NotificationsManager.in_app_notification(notification)
          end
          notification
        end
      end
    end

    class << self
      def create_bulk_notification(models, journals, project_id, from_id)
        if RORganize::Application.config.enable_emails_notifications

          notification = NotifiableBulkEditEvent.new(models, journals, project_id, from_id)
          if notification.recipients_hash.any?
            send_emails_bulk_edit(notification)
            in_app_bulk_edit_notifications(notification)
          end
          notification
        end
      end
      # Send email to recipients.
      # @param [NotifiableEvent] notification : the notification event object.
      def send_emails(notification)
        if notification.notification_type.eql?(NotifiableEvent::GENERIC_NOTIFICATION)
          notification.recipients = real_recipients(notification, 'email').values.flatten.compact
          if notification.recipients.any?
            NotificationMailer.delay.notification_email(notification)
          end
        elsif notification.notification_type.eql?(NotifiableEvent::MEMBER_NOTIFICATION)
          NotificationMailer.delay.welcome_new_member_email(notification)
          NotificationMailer.delay.member_join_email(notification)
        end
      end

      def send_emails_bulk_edit(notification_bulk_edit)
        notification_bulk_edit.recipients = real_recipients(notification_bulk_edit, 'email').values.flatten.compact
        if notification_bulk_edit.recipients.any?
          NotificationMailer.delay.notification_bulk_edit_email(notification_bulk_edit)
        end
      end

      # Create all @see Notification object.
      # @param [NotifiableEvent] notification : the notification event object.
      def in_app_notification(notification)
        if notification.notification_type.eql?(NotifiableEvent::GENERIC_NOTIFICATION)
          notification.recipients = notification.recipients_hash.values
          insert = []
          user_ids = []
          created_at = Time.now.utc.to_formatted_s(:db)
          real_recipients(notification, 'in_app').each do |key, users|
            users.each do |user|
              insert << "(#{notification.model.id}, '#{notification.model.class}','#{notification.trigger.class}', #{notification.trigger.id}, #{user[:id]}, '#{notification.trigger.user_id}', '#{key}', #{notification.project.id}, '#{created_at}')"
              user_ids << user[:id]
            end
          end
          if insert.any?
            Notification.delete_all(user_id: user_ids, notifiable_id: notification.model.id, notifiable_type: notification.model.class)
            sql = "INSERT INTO `notifications` (`notifiable_id`, `notifiable_type`, `trigger_type`, `trigger_id`, `user_id`, `from_id`, `recipient_type`, `project_id`, `created_at`) VALUES #{insert.join(', ')}"
            Notification.connection.execute(sql)
          end
        end
      end

      def in_app_bulk_edit_notifications(notification_bulk_edit)
        notification_bulk_edit.recipients = notification_bulk_edit.recipients_hash.values
        insert = []
        user_ids = []
        ids = []
        created_at = Time.now.utc.to_formatted_s(:db)
        real_recipients(notification_bulk_edit, 'in_app').each do |key, users|
          users.each do |user|
            notification_bulk_edit.objects.each do |model|
              ids << model[:id]
              insert << "(#{model[:id]}, '#{notification_bulk_edit.type}','Journal', #{notification_bulk_edit.journals_hash[model[:id]]}, #{user[:id]}, '#{notification_bulk_edit.from_id}', '#{key}', #{notification_bulk_edit.project.id}, '#{created_at}')"
              user_ids << user[:id]
            end
          end
        end
        if insert.any?
          Notification.delete_all(user_id: user_ids, notifiable_id: ids, notifiable_type: notification_bulk_edit.type)
          sql = "INSERT INTO `notifications` (`notifiable_id`, `notifiable_type`, `trigger_type`, `trigger_id`, `user_id`, `from_id`, `recipient_type`, `project_id`, `created_at`) VALUES #{insert.join(', ')}"
          Notification.connection.execute(sql)
        end
      end

      # This method collect recipients, who want to receive the notification (as defined in their preferences).
      # E.g : if type.eql? 'email', recipients are user that want to receive notification emails.
      # @param [NotifiableEvent] notification : the notification event object.
      # @param [String] type : must be 'in_app' or 'email'. Define the kind of notification output.
      def real_recipients(notification, type)
        enumeration_watcher = Preference.keys["notification_watcher_#{type}".to_sym]
        enumeration_participant = Preference.keys["notification_participant_#{type}".to_sym]
        tmp_hash = {}
        notification.recipients_hash.each do |key, users|
          tmp_hash[key] = []
          users.each do |user|
            enum_preference_ids = user.preferences.collect { |pref| Preference.notification_keys[pref.key.to_sym] }
            if key.eql?(:participants) && enum_preference_ids.include?(enumeration_participant) ||
                key.eql?(:watchers) && enum_preference_ids.include?(enumeration_watcher)
              tmp_hash[key] << {id: user.id, email: user.email}
            end
          end
        end
        tmp_hash
      end
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
        @recipients_hash = {}
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

      # Find all recipients of the notification. @see below find_participants and @see below find_author.
      def find_recipients
        participants = find_participants
        watchers = find_watchers
        @recipients_hash[:participants] = participants.compact
        @recipients_hash[:watchers] = watchers.compact
      end

      # @return [Array] an array of users who are participating to the "model" object.
      # Participate mean:
      # * be assigned if "model" is an issue.
      # * be mentioned in description of the "model".
      # * be mentioned in a comment of the "model".
      # * participate of the "model" discussion(comments) thread.
      def find_participants
        participants = []
        model_assigned_to = nil
        mentioned_slugs = []
        if @model
          if @trigger.is_a?(Journal)
            model_assigned_to = @model.assigned_to if @model.respond_to?(:assigned_to)
            mentioned_slugs |= @model.description.scan(/@[^\s]+/) if @model.respond_to?(:description)
          elsif @trigger.is_a? Comment
            mentioned_slugs |= @trigger.content.scan(/@[^\s]+/)
            participants |= @trigger.thread.collect { |comment| comment.author unless comment.eql?(@trigger) }
          end
          participants << model_assigned_to
          mentioned_slugs = mentioned_slugs.map { |slug| slug.gsub(/@/, '') unless slug.eql?(User.current.slug) }
          participants |= User.where(slug: mentioned_slugs).eager_load(:preferences) if mentioned_slugs.any?
        end
        participants.delete_if { |user| user.eql?(from) }
      end

      # @return [Array] an array of users who are watching the "model" object, Except the user who perform the action.
      def find_watchers
        @model.respond_to?(:real_watchers) ? @model.real_watchers.collect { |watcher| watcher.author unless watcher.author.eql?(from) } : []
      end

      # @return [User] the user who perform the action.
      def from
        if @trigger.is_a? Journal
          @trigger.user
        elsif @trigger.is_a? Comment
          @trigger.author
        end
      end

      # @return [Hash] a hash for url of the "model" to create a link in emails.
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

    class NotifiableBulkEditEvent
      attr_accessor :recipients, :recipients_hash, :objects, :project, :journal, :from_id, :type, :journals_hash

      def initialize(objects, journals, project_id, from_id)
        @objects = objects.collect { |model| {id: model.id, caption: model.caption} }
        @type = objects[0].class
        @journals_hash = {}
        journals.each do |journal|
          @journals_hash[journal.journalizable_id] = journal.id
        end
        @from_id = from_id
        @journal = journals[0]
        @project = Project.find_by_id(project_id)
        @recipients = []
        @recipients_hash = {participants: find_participants(objects), watchers: find_watchers(objects, project_id)}
      end

      def find_watchers(objects, project_id)
        ids = objects.collect { |obj| obj.id }
        unwatch = Watcher.includes(author: :preferences).where(watchable_type: self.to_s, watchable_id: ids, is_unwatch: true, project_id: project_id).pluck('user_id')
        w = Watcher.includes(author: :preferences).where(watchable_type: self.to_s, watchable_id: ids, project_id: project_id)
        project_w = Watcher.includes(author: :preferences).where(watchable_type: 'Project', watchable_id: project_id)
        sum = project_w.to_a + w.to_a
        sum.flatten(0).delete_if { |watcher| unwatch.include? watcher.user_id }.collect { |watcher| watcher.author unless watcher.author.eql?(User.current) }.compact
      end

      def find_participants(objects)
        if self.eql?(Issue)
          objects.collect { |obj| obj.assigned_to unless obj.assigned_to.eql?(User.current) }.compact
        else
          []
        end
      end

      # @return [Hash] a hash for url of the "model" to create a link in emails.
      def model_url
        controller = nil
        action = 'show'
        case @type.to_s
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