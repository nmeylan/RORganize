# Author: Nicolas Meylan
# Date: 1 juil. 2012
# Encoding: UTF-8
# File: member.rb

class Member < RorganizeActiveRecord
  include Rorganize::AbstractModelCaption
  #Constants
  assign_journalized_properties({'role_id' => 'Role'})
  assign_foreign_keys({'role_id' => Role})
  #Relations
  belongs_to :project, :class_name => 'Project', counter_cache: true
  
  belongs_to :user, :class_name => 'User'
  belongs_to :role, :class_name => 'Role'
  has_many :journals, -> { where :journalized_type => 'Member'}, :dependent => :destroy, :as => :journalized
  #Triggers
  before_create :set_project_position
  after_create :create_journal
  after_update :update_journal
  after_destroy :destroy_journal
  #Methods
  def caption
    self.user.name
  end
  
  def create_journal
    created_journalized_attributes = {'role_id' => [nil, self.role_id]}
    journal = Journal.create(:user_id => User.current.id,
      :journalized_id => self.id,
      :journalized_type => self.class.to_s,
      :notes => '',
      :action_type => 'created',
      :project_id => self.project_id)
    journal.detail_insertion(created_journalized_attributes, self.class.journalized_properties, self.class.foreign_keys)
  end

  #Get activities for a project member
  def activities
    Journal.where(:user_id => self.user_id, :project_id => self.project_id)
    .includes(:details, :project, :user, :journalized)
    .order('created_at DESC')
  end

  #Change a member's role
  def change_role(value)
    success = self.update_attribute(:role_id, value)
    members = Member.where(:project_id => self.project.id).includes(:role, :user)
    {:saved => success, :members => members}
  end

  def self.find_members_and_roles_by_project_id(project_id)
    members = Member.where(:project_id => project_id).includes(:role, :user)
    roles = Role.select('*')
    {:members => members, :roles => roles}
  end

  def set_project_position
    self.project_position = Member.where(:user_id => self.user_id).count
  end
  
end
