# Author: Nicolas Meylan
# Date: 27.07.14
# Encoding: UTF-8
# File: commentable.rb
module Rorganize
  module Watchable
    extend ActiveSupport::Concern
    included do |base|
      has_many :watchers, -> { (where watchable_type: base).eager_load(:project, :author) }, as: :watchable, dependent: :destroy
    end

    def watch_by?(user)
       w = self.watchers.to_a.delete_if{|watcher| !watcher.user_id.eql?(user.id)}[0]
      # w = Watcher.where(user_id: user.id, watchable_type: self.class.to_s, watchable_id: self.id).first
      is_a_project = self.is_a?(Project)
      parent_watch = parent_watch_by?(user)
      (!is_a_project && ((parent_watch &&(w.nil? || (w && !w.is_unwatch))) ||(!parent_watch && (w && !w.is_unwatch)))) || (is_a_project && !w.nil?)
    end

    def watcher_for(user)
      w = self.watchers.to_a.delete_if{|watcher| !watcher.user_id.eql?(user.id) && watcher.is_unwatch}[0]
      w = Watcher.where(user_id: user.id, watchable_type: 'Project', watchable_id: self.project_id, is_unwatch: false).first if w.nil? && !self.is_a?(Project)
      w
    end

    def real_watchers
      unwatch = Watcher.includes(author: :preferences).where(watchable_type: self.class.to_s, watchable_id: self.id, is_unwatch: true, project_id: self.project_id).pluck('user_id')
      w = Watcher.includes(author: :preferences).where(watchable_type: self.class.to_s, watchable_id: self.id, project_id: self.project_id)
      project_w = Watcher.includes(author: :preferences).where(watchable_type: 'Project', watchable_id: self.project_id) if !self.is_a?(Project)
      sum = project_w.to_a + w.to_a
      sum.flatten(0).delete_if{|watcher| unwatch.include? watcher.user_id}
    end

    def parent_watch_by?(user)
      !self.is_a?(Project) && Watcher.where(user_id: user.id, watchable_type: self.project.class.to_s, watchable_id: self.project.id).any?
    end

  end
end