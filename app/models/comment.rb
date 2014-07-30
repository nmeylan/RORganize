# Author: Nicolas Meylan
# Date: 27.07.14
# Encoding: UTF-8
# File: comment.rb

class Comment < ActiveRecord::Base
  include Rorganize::JounalsManager
  ACTIVITIES_PERIODS = {ONE_DAY: 1, THREE_DAYS: 3, ONE_WEEK: 7, ONE_MONTH: 31}
  belongs_to :author, class_name: 'User', foreign_key: :user_id
  belongs_to :commentable, :polymorphic => true
  belongs_to :issue, foreign_key: 'commentable_id'
  belongs_to :project

  scope :comments, ->(commentable_type, date_range, conditions = '1 = 1') { eager_load(author: :avatar).where("commentable_type IN (?) AND #{conditions}", commentable_type).where(created_at: date_range).order('comments.created_at DESC')}

  validates :content, presence: true
  before_update :update_date

  def self.comments_eager_load(commentable_types, period, date, conditions)
    periods = ACTIVITIES_PERIODS
    date = date.to_date + 1
    date_range = (date - periods[period.to_sym])..date

    query = self.comments(commentable_types, date_range, conditions)
    query
  end

  def update_date
    self.updated_at = Time.now
  end

  def edited?
    self.created_at < self.updated_at
  end

  def self.permit_attributes
    [:commentable_id, :commentable_type, :content, :parent_id, :project_id]
  end

  def polymorphic_identifier
    "#{self.commentable_type}_#{self.commentable_id}".to_sym
  end


end