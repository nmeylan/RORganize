# Author: Nicolas Meylan
# Date: 1 juil. 2012
# Encoding: UTF-8
# File: member.rb

class Member < ActiveRecord::Base
  belongs_to :project, :class_name => 'Project'
  belongs_to :user, :class_name => 'User'
  belongs_to :role, :class_name => 'Role'
end
