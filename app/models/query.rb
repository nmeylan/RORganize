# Author: Nicolas Meylan
# Date: 5 févr. 2013
# Encoding: UTF-8
# File: query.rb

class Query < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged
  
  belongs_to :project
  belongs_to :user, :foreign_key => :author_id
  validates :name, :stringify_query, :stringify_params, :object_type, :presence => true
  validates :name, :uniqueness => true

  def self.permit_attributes
    [:is_for_all, :is_public, :name, :description, :object_type]
  end

  def self.issues_queries(project_id)
    self.where('(project_id = ? AND (author_id = ? OR is_public = ?)) OR (is_for_all = ? AND (author_id = ? OR is_public = ?)) AND object_type = ?', project_id, User.current.id, true, true, User.current.id, true, Issue.to_s)
  end

  def self.project_queries(project_id, author_id)
    self.where('(project_id = ? AND (author_id = ? OR is_public = ?))
        OR (is_for_all = ? AND (author_id = ? OR is_public = ?))', project_id, author_id, true, true, author_id, true )
  end

  def self.public_queries(project_id)
    self.where('project_id = ? AND is_public = ? AND is_for_all = ?', project_id, true, false)
  end
end
