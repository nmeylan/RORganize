# Author: Nicolas Meylan
# Date: 5 févr. 2013
# Encoding: UTF-8
# File: query.rb

class Query < ActiveRecord::Base
  include SmartRecords
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :project
  belongs_to :user, foreign_key: :author_id
  #Validators
  validates :name, :stringify_query, :stringify_params, :object_type, presence: true
  validates :name, uniqueness: true, length: 2..50
  #Scopes
  scope :available_for, ->(user, project_id, type) {
    where('((project_id = ? AND (author_id = ? OR is_public = ?)) OR
            (is_for_all = ? AND (author_id = ? OR is_public = ?))) AND object_type = ?',
          project_id, user.id, true, true, user.id, true, type)
  }

  scope :created_by, ->(user) { where(['author_id = ? AND is_public = ?', user.id, false]) }

  scope :public_queries, ->(project_id) {
    where('project_id = ? AND is_public = ? AND is_for_all = ?', project_id, true, false)
  }

  def self.permit_attributes
    [:is_for_all, :is_public, :name, :description, :object_type, :id]
  end

  def caption
    self.name
  end

  # @param [Hash] attributes : query attributes.
  # @param [Project] project : the project to which the query belongs to.
  # @param [Hash] params_filter : a hash with the following structure
  # {attribute_name:String => {"operator"=> String, "value"=> String}}
  # attribute_name is the name of the attribute on which criterion is based
  # E.g : {"subject"=>{"operator"=>"contains", "value"=>"test"}}.
  def self.create_query(attributes, project, params_filter)
    query = self.new(attributes)
    query.user = User.current
    query.project = project
    # Calls conditions_string method to an AR Object (e.g : Issue, Document)
    filter = query.object_type.constantize.conditions_string(params_filter) if query.object_type
    query.stringify_query = filter
    query.stringify_params = params_filter.inspect
    query
  end

end
