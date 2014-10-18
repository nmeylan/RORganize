# Author: Nicolas Meylan
# Date: 7 juil. 2012
# Encoding: UTF-8
# File: Role.rb

class Role < ActiveRecord::Base
  include Rorganize::Models::SmartRecords

  has_many :members, class_name: 'Member', dependent: :nullify
  has_and_belongs_to_many :issues_statuses, -> { includes([:enumeration]) }, class_name: 'IssuesStatus'
  has_and_belongs_to_many :permissions, class_name: 'Permission'
  # This relation is use, when a member with a defined role whant to assigne role for another member.
  has_and_belongs_to_many :assignable_roles, class_name: 'Role', join_table: 'assignable_roles', foreign_key: 'assignable_by_role_id', dependent: :destroy
  # has_many :assignable_by_roles, class_name: 'Role', through: 'AssignableRole', foreign_key: 'role_id'
  scope :non_member, -> { where(name: Rorganize::NON_MEMBER_ROLE).first }
  validates :name, presence: true, uniqueness: true, length: 2..255

  def self.permit_attributes
    [:name]
  end

  def caption
    self.name
  end

  def update_permissions(permissions_param)
    if permissions_param
      permissions_id = permissions_param.values
      permissions = Permission.where(id: permissions_id)
      self.permissions.clear
      permissions_id.each do |permission_id|
        permission = permissions.select { |perm| perm.id == permission_id.to_i }
        self.permissions << permission
      end
    end
    self.save
  end

  def self.update_role_attributes(role_params, params)
    role = params[:id] ? self.find_by_id(params[:id]) : Role.new(role_params)
    role.attributes = role_params
    role.set_statuses(params[:issues_statuses])
    role.set_assignable_roles(params[:roles])
    role
  end

  def set_statuses(statuses)
    if statuses && statuses.any?
      self.issues_statuses.clear
      issues_statuses = IssuesStatus.where(id: statuses.values)
      issues_statuses.each { |status| self.issues_statuses << status }
    end
  end

  def set_assignable_roles(role_ids)
    if role_ids && role_ids.any?
      self.assignable_roles.clear
      roles = Role.where(id: role_ids.values)
      roles.each{|role| self.assignable_roles << role}
    end
  end
end
