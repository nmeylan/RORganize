# Author: Nicolas Meylan
# Date: 13 juil. 2012
# Encoding: UTF-8
# File: tracker.rb

class Tracker < ActiveRecord::Base
  include Rorganize::SmartRecords

  has_and_belongs_to_many :projects, :class_name => 'Project'
  has_many :issues, :class_name => 'Issue', :dependent => :nullify

  validates :name, :presence => true, :uniqueness => true, :length => 2..50

  def caption
    self.name
  end
  def self.permit_attributes
    [:name]
  end
end
