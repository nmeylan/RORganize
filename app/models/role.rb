# Author: Nicolas Meylan
# Date: 7 juil. 2012
# Encoding: UTF-8
# File: Role.rb

class Role < ActiveRecord::Base
  has_many :members, :class_name => 'Member', :dependent => :nullify
  has_and_belongs_to_many :issues_statuses, :class_name => 'IssuesStatus', :include => [:enumeration]
  has_and_belongs_to_many :permissions, :class_name => 'Permission'

  validates :name, :presence => true, :uniqueness => true
end
