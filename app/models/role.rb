# Author: Nicolas Meylan
# Date: 7 juil. 2012
# Encoding: UTF-8
# File: Role.rb

class Role < ActiveRecord::Base
  include SmartRecords

  has_many :members, class_name: 'Member', dependent: :nullify
  has_and_belongs_to_many :issues_statuses, -> { includes([:enumeration]) }, class_name: 'IssuesStatus'
  has_and_belongs_to_many :permissions, class_name: 'Permission'
  # this relations symbolise which roles (role_id) can be granted for a given role (assignable_by_role_id).
  # E.g : a ProjectManager can assign "TeamMember" and "ProjectManager" roles to members.
  # But an EngagementManager can assign "TeamMember", "ProjectManager" and "EngagementManager" roles to members.
  has_and_belongs_to_many :assignable_roles, class_name: 'Role', join_table: 'assignable_roles',
                          foreign_key: 'assignable_by_role_id', dependent: :destroy

  scope :non_member, -> { where(name: Rorganize::NON_MEMBER_ROLE).first }
  scope :all_non_locked, -> { where(is_locked: false) }

  validates :name, presence: true, uniqueness: true, length: 2..255

  def self.permit_attributes
    [:name, issues_status_ids: [], assignable_role_ids: []]
  end

  def caption
    self.name
  end

  def update_permissions(permissions_param)
    if permissions_param
      permissions_id = permissions_param.values
      permissions = Permission.where(id: permissions_id)
      self.permissions.clear
      self.permissions = permissions.to_a
    end
    self.save
  end
end
