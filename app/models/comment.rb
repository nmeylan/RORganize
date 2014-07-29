# Author: Nicolas Meylan
# Date: 27.07.14
# Encoding: UTF-8
# File: comment.rb

class Comment < ActiveRecord::Base
  include Rorganize::JounalsManager

  belongs_to :author, class_name: 'User', foreign_key: :user_id
  belongs_to :commentable, :polymorphic => true

  validates :content, presence: true
  before_update :update_date

  def update_date
    self.updated_at = Time.now
  end

  def edited?
    self.created_at < self.updated_at
  end

  def self.permit_attributes
    [:commentable_id, :commentable_type, :content, :parent_id]
  end


end