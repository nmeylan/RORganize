# Author: Nicolas Meylan
# Date: 1 juil. 2012
# Encoding: UTF-8
# File: member.rb

class Member < ActiveRecord::Base
  default_scope joins(:project,:role, :user)
  belongs_to :project, :class_name => 'Project'
  belongs_to :user, :class_name => 'User'
  belongs_to :role, :class_name => 'Role'
  has_many :journals, :as => :journalized, :conditions => {:journalized_type => self.to_s}, :dependent => :destroy

  def name
    return self.user.name
  end
end
