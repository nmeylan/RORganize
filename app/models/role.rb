# Author: Nicolas Meylan
# Date: 7 juil. 2012
# Encoding: UTF-8
# File: Role.rb

class Role < ActiveRecord::Base
  has_many :members, :class_name => 'Member', :dependent => :nullify
  has_and_belongs_to_many :issues_statuses, :class_name => 'IssuesStatus', :include => [:enumeration]
  has_and_belongs_to_many :permissions, :class_name => 'Permission'

  validates :name, :presence => true, :uniqueness => true

  def update_permissions(permissions_param)
    if permissions_param
      permissions_id = permissions_param.values
      permissions = Permission.find_all_by_id(permissions_id)
      self.permissions.clear
      permissions_id.each do |permission_id|
        permission = permissions.select{|perm| perm.id == permission_id.to_i }
        self.permissions << permission
      end
    end
    self.save
  end
end
