# Author: Nicolas Meylan
# Date: 14 juil. 2012
# Encoding: UTF-8
# File: IssueStatus.rb

class IssuesStatus < ActiveRecord::Base
  has_and_belongs_to_many :roles, :class_name => 'Role'
  belongs_to :enumeration, :class_name => 'Enumeration'
  has_many :issues, :class_name => 'Issue', :dependent => :nullify
end

