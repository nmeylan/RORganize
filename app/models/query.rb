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
end
