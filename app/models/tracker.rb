# Author: Nicolas Meylan
# Date: 13 juil. 2012
# Encoding: UTF-8
# File: tracker.rb

class Tracker < ActiveRecord::Base
  include Rorganize::AbstractModelCaption
  has_and_belongs_to_many :projects, :class_name => 'Project'
  has_many :issues, :class_name => 'Issue', :dependent => :nullify

  def caption
    self.name
  end
  def self.permit_attributes
    [:name]
  end
end
