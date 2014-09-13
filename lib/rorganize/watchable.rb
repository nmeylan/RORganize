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
      !watcher_for(user).nil?
    end

    def watcher_for(user)
      Watcher.where(user_id: user.id, watchable_type: self.class.to_s, watchable_id: self.id).first
    end

  end
end