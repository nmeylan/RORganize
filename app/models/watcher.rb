# Author: Nicolas Meylan
# Date: 13.09.14
# Encoding: UTF-8
# File: watcher.rb

class Watcher < ActiveRecord::Base
  belongs_to :author, class_name: 'User', foreign_key: :user_id
  belongs_to :watchable, polymorphic: true
  belongs_to :project

  validates :user_id, presence: true

  def self.permit_attributes
    [:watchable_id, :watchable_type]
  end

end