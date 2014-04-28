# Author: Nicolas Meylan
# Date: 7 juil. 2012
# Encoding: UTF-8
# File: Role.rb

class Role < ActiveRecord::Base
  has_many :members, :class_name => 'Member', :dependent => :nullify
  has_and_belongs_to_many :issues_statuses, -> {includes([:enumeration])}, :class_name => 'IssuesStatus'
  has_and_belongs_to_many :permissions, :class_name => 'Permission'

  validates :name, :presence => true, :uniqueness => true

  def self.permit_attributes
    [:name]
  end

  def update_permissions(permissions_param)
    if permissions_param
      permissions_id = permissions_param.values
      permissions = Permission.where(:id => permissions_id)
      self.permissions.clear
      permissions_id.each do |permission_id|
        permission = permissions.select { |perm| perm.id == permission_id.to_i }
        self.permissions << permission
      end
    end
    self.save
  end

  def set_statuses(statuses)
    if statuses && statuses.any?
      self.issues_statuses.clear
      issues_statuses = IssuesStatus.where(:id => statuses.values)
      issues_statuses.each { |status| self.issues_statuses << status }
    end
  end
end
