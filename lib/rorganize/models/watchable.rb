# Author: Nicolas Meylan
# Date: 27.07.14
# Encoding: UTF-8
# File: commentable.rb
module Rorganize
  module Models
    module Watchable
      extend ActiveSupport::Concern
      included do |base|
        has_many :watchers, -> { (where watchable_type: base).eager_load(:project, :author) }, as: :watchable, dependent: :destroy
      end

      def watch_by?(user)
        w = self.watchers.to_a.delete_if { |watcher| !watcher.user_id.eql?(user.id) }[0]
        # w = Watcher.where(user_id: user.id, watchable_type: self.class.to_s, watchable_id: self.id).first
        is_a_project = self.is_a?(Project)
        parent_watch = parent_watch_by?(user)
        is_watched?(is_a_project, parent_watch, w)
      end

      def is_watched?(is_a_project, parent_watch, w)
        (!is_a_project && (parent_is_watched?(parent_watch, w) || is_not_excluded(parent_watch, w))) || project_is_watched?(is_a_project, w)
      end

      def project_is_watched?(is_a_project, w)
        (is_a_project && !w.nil?)
      end

      def is_not_excluded(parent_watch, w)
        (!parent_watch && (w && !w.is_unwatch))
      end

      def parent_is_watched?(parent_watch, w)
        (parent_watch &&(w.nil? || (w && !w.is_unwatch)))
      end

      def watcher_for(user)
        w = self.watchers.to_a.delete_if { |watcher| !watcher.user_id.eql?(user.id) && watcher.is_unwatch }[0]
        w = Watcher.where(user_id: user.id, watchable_type: 'Project', watchable_id: self.project_id, is_unwatch: false).first if w.nil? && !self.is_a?(Project)
        w
      end

      def real_watchers
        unwatch = excluded_watchables
        w = user_watchers
        project_w = parent_watchers if !self.is_a?(Project)
        sum = project_w.to_a + w.to_a
        sum.flatten(0).delete_if { |watcher| unwatch.include? watcher.user_id }
      end

      def parent_watchers
        Watcher.includes(author: :preferences).where(watchable_type: 'Project', watchable_id: self.project_id)
      end

      def user_watchers
        Watcher.includes(author: :preferences).where(watchable_type: self.class.to_s, watchable_id: self.id, project_id: self.project_id)
      end

      def excluded_watchables
        Watcher.includes(author: :preferences).where(watchable_type: self.class.to_s, watchable_id: self.id, is_unwatch: true, project_id: self.project_id).pluck('user_id')
      end

      def parent_watch_by?(user)
        !self.is_a?(Project) && Watcher.where(user_id: user.id, watchable_type: self.project.class.to_s, watchable_id: self.project.id).any?
      end

      class << self
        def bulk_delete_dependent(watchable_ids, class_name)
          Watcher.delete_all(watchable_id: watchable_ids, watchable_type: class_name)
        end
      end
    end
  end
end