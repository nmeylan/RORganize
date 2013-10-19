# Author: Nicolas Meylan
# Date: 1 juil. 2012
# Encoding: UTF-8
# File: member.rb

class Member < RorganizeActiveRecord
  #Constants
  assign_journalized_properties({'role_id' => 'Role'})
  assign_foreign_keys({'role_id' => Role})
  assign_journalized_icon('/assets/activity_group.png')
  #Relations
  belongs_to :project, :class_name => 'Project'
  
  belongs_to :user, :class_name => 'User'
  belongs_to :role, :class_name => 'Role'
  has_many :journals, :as => :journalized, :conditions => {:journalized_type => self.to_s}, :dependent => :destroy
  #Triggers
  after_create :create_journal
  after_update :update_journal
  after_destroy :destroy_journal
  #Methods
  def name
    return self.user.name
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
  
end
