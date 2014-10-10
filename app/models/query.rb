# Author: Nicolas Meylan
# Date: 5 févr. 2013
# Encoding: UTF-8
# File: query.rb

class Query < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :project
  belongs_to :user, foreign_key: :author_id
  #Validators
  validates :name, :stringify_query, :stringify_params, :object_type, presence: true
  validates :name, uniqueness: true, length: 2..50
  #Scopes
  scope :available_for, ->(user, project_id) { where('(project_id = ? AND (author_id = ? OR is_public = ?)) OR (is_for_all = ? AND (author_id = ? OR is_public = ?)) AND object_type = ?', project_id, user.id, true, true, user.id, true, Issue.to_s) }
  scope :created_by, ->(user) { where(['author_id = ? AND is_public = false', user.id]) }
  scope :public_queries, ->(project_id) { where('project_id = ? AND is_public = ? AND is_for_all = ?', project_id, true, false) }

  def self.permit_attributes
    [:is_for_all, :is_public, :name, :description, :object_type, :id]
  end

  def caption
    self.name
  end

end
