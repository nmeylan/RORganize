# Author: Nicolas Meylan
# Date: 27.07.14
# Encoding: UTF-8
# File: comment.rb

class Comment < ActiveRecord::Base
  include Rorganize::Managers::NotificationsManager
  ACTIVITIES_PERIODS = {ONE_DAY: 1, THREE_DAYS: 3, ONE_WEEK: 7, ONE_MONTH: 31}

  belongs_to :author, class_name: 'User', foreign_key: :user_id
  belongs_to :commentable, polymorphic: true
  belongs_to :issue, foreign_key: 'commentable_id', counter_cache: true
  belongs_to :document, foreign_key: 'commentable_id', counter_cache: true
  belongs_to :project

  scope :fetch_dependencies_issues, -> { includes(issue: :tracker) }

  scope :comments, ->(commentable_type, date_range, conditions = '1 = 1') {
    eager_load(:project)
        .where("commentable_type IN (?)", commentable_type)
        .where(conditions)
        .where(created_at: date_range)
        .order('comments.created_at DESC') }

  default_scope { eager_load(author: :avatar) }
  validates :content, :project_id, :commentable_id, :commentable_type, presence: true
  before_update :update_date

  # Build a scope that eager load all comments for the given object type
  # for a given time range.
  # @param [Array] commentable_types : an array of the commented objects types (e.g: Issue, Document...)
  # @param [Symbol] period : one of the followings values : :ONE_DAY, :THREE_DAYS, :ONE_WEEK, :ONE_MONTH
  # @param [Date] date : The end date of the range.
  # @param [String] conditions : extra condition for the scope.
  def self.comments_eager_load(commentable_types, period, date, conditions)
    date_range = build_date_range(date, period)

    query = self.comments(commentable_types, date_range, conditions)
    query = query.fetch_dependencies_issues if commentable_types.include?('Issue')
    query = query.preload(:commentable)
    query
  end

  # Build a range from given date - period to given date.
  # @param [Date] date : The end date of the range.
  # @param [Symbol] period : one of the followings values : :ONE_DAY, :THREE_DAYS, :ONE_WEEK, :ONE_MONTH
  def self.build_date_range(date, period)
    periods = ACTIVITIES_PERIODS
    date = date.to_date + 1
    (date - periods[period.to_sym])..date
  end

  def update_date
    self.updated_at = Time.now
  end

# @return [Boolean] true if the comment was edited.
  def edited?
    self.created_at < self.updated_at
  end

# @param [User] user.
# @return [Boolean] true if given user is the author, false otherwise.
  def author?(user)
    self.author.id.eql? user.id
  end

  def self.permit_attributes
    [:commentable_id, :commentable_type, :content, :parent_id, :project_id]
  end

  def polymorphic_identifier
    "#{self.commentable_type}_#{self.commentable_id}".to_sym
  end

  def thread_comment_count
    self.thread.count
  end

  def thread
    Comment.where(commentable_id: self.commentable_id, commentable_type: self.commentable_type)
  end


end