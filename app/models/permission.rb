# Author: Nicolas Meylan
# Date: 12 oct. 2012
# Encoding: UTF-8
# File: permission.rb

class Permission < ActiveRecord::Base
  include Rorganize::Models::SmartRecords

  has_and_belongs_to_many :roles, :class_name => 'Role'

  validates :name, :controller, :action, :presence => true

  def self.permit_attributes
    [:name, :action, :controller]
  end

  def caption
    self.name
  end

end
