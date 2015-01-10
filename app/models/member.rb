# Author: Nicolas Meylan
# Date: 1 juil. 2012
# Encoding: UTF-8
# File: member.rb

class Member < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  include Rorganize::Models::Journalizable
  include Rorganize::Models::Watchable
  #Constants
  exclude_attributes_from_journal(:is_project_starred, :project_position)
  #Relations
  belongs_to :project, class_name: 'Project', counter_cache: true

  belongs_to :user, class_name: 'User'
  belongs_to :role, class_name: 'Role'
  has_many :assigned_issues, -> { where('issues.project_id = members.project_id') }, through: :user, class_name: 'Issue'
  #Triggers
  before_create :remove_old_member_role, :set_project_position
  after_create :dec_counter_cache
  after_destroy :unassigned_issues, :remove_watchers, :inc_counter_cache

  validates_uniqueness_of :user_id, scope: [:project_id, :role_id]
  validates :role_id, :project_id, :user_id, presence: true
  validate :project_is_public_when_adding_non_member
  #Scopes
  scope :fetch_dependencies, -> { includes(:role, :user) }
  scope :members_by_project, -> (project_id, current_page, per_page, order) {
    where(project_id: project_id)
        .where('members.role_id <> ?', Role.non_member.id)
        .paginated(current_page, per_page, order, [:role, :user])
  }
  #Methods
  def caption
    self.user.name
  end

  def create_journal
    unless self.role_id.eql?(Role.non_member.id)
      created_journalizable_attributes = {role_id: [nil, self.role_id]}
      journal = Journal.create(user_id: User.current.id,
                               journalizable_id: self.id,
                               journalizable_type: self.class.to_s,
                               journalizable_identifier: self.caption,
                               notes: '',
                               action_type: 'created',
                               project_id: self.project_id)
      journal.detail_insertion(Member, created_journalizable_attributes)
    end
  end

  #Change a member's role
  def change_role(role_id)
    success = self.update_attribute(:role_id, role_id)
    members = Member.where(project_id: self.project.id).eager_load(:role, :user)
    {saved: success, members: members}
  end

  def set_project_position
    self.project_position = Member.where(user_id: self.user_id).count
  end

  def unassigned_issues
    Issue.where({assigned_to: self.user_id}).update_all({assigned_to_id: nil})
  end

  # When user is no longer a team member, he should lose his watchers on this project items.
  def remove_watchers
    Watcher.delete_all(project_id: self.project_id, user_id: self.user_id)
  end

  # If member was a non member on the project, then drop his old role and replaced by the new one.
  def remove_old_member_role
    Member.delete_all(project_id: self.project_id, user_id: self.user_id)
  end

  def dec_counter_cache
    Project.update_counters(self.project_id, members_count: -1) if self.role_id.eql?(Role.non_member.id)
  end

  def inc_counter_cache
    Project.update_counters(self.project_id, members_count: 1) if self.role_id.eql?(Role.non_member.id)
  end

  def project_is_public_when_adding_non_member
    if self.role.eql?(Role.non_member) && self.project && !self.project.is_public
      errors.add(:role, 'cannot be Non member when project is private.')
    end
  end
end
