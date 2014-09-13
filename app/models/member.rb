# Author: Nicolas Meylan
# Date: 1 juil. 2012
# Encoding: UTF-8
# File: member.rb

class Member < ActiveRecord::Base
  include Rorganize::SmartRecords
  include Rorganize::Journalizable
  include Rorganize::Watchable
  #Constants
  assign_journalizable_properties({role_id: 'Role'})
  assign_foreign_keys({role_id: Role})
  #Relations
  belongs_to :project, :class_name => 'Project', counter_cache: true

  belongs_to :user, :class_name => 'User'
  belongs_to :role, :class_name => 'Role'
  has_many :assigned_issues, -> { where('issues.project_id = members.project_id') }, through: :user, class_name: 'Issue'
  #Triggers
  before_create :set_project_position
  before_destroy :unassigned_issues
  #Scopes
  scope :fetch_dependencies, -> { eager_load(:role, :user) }
  #Methods
  def caption
    self.user.name
  end

  def create_journal
    unless self.role_id.eql?(Role.non_member.id)
      created_journalizable_attributes = {:role_id => [nil, self.role_id]}
      journal = Journal.create(:user_id => User.current.id,
                               :journalizable_id => self.id,
                               :journalizable_type => self.class.to_s,
                               :journalizable_identifier => self.caption,
                               :notes => '',
                               :action_type => 'created',
                               :project_id => self.project_id)
      journal.detail_insertion(created_journalizable_attributes, self.class.journalizable_properties, self.class.foreign_keys)
    end
  end

  #Change a member's role
  def change_role(value)
    success = self.update_attribute(:role_id, value)
    members = Member.where(:project_id => self.project_decorator.id).eager_load(:role, :user)
    {:saved => success, :members => members}
  end

  def set_project_position
    self.project_position = Member.where(:user_id => self.user_id).count
  end

  def unassigned_issues
    Issue.where({assigned_to: self.user_id}).update_all({assigned_to_id: nil})
  end

end
