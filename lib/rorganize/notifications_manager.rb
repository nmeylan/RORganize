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
          notification = Notification.new(self)
          NotificationMailer.delay.notification_email(notification) if notification.recipients.any?
          notification
        end
      end
    end


    class Notification
      attr_reader :recipients, :project, :trigger, :model, :model_url

      def initialize(trigger)
        @trigger = trigger
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
          @recipients = find_recipients.compact
        else
          @recipients = []
        end
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
        watchers |= @model.watchers.collect{|watcher| watcher.author} if @model.respond_to?(:watchers)
        p watchers
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