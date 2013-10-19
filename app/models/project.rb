class Project < ActiveRecord::Base
  #SLug
  extend FriendlyId
  friendly_id :identifier, use: :slugged
  after_create :create_member
  after_update :save_attachments
  
  belongs_to :author, :class_name => 'User', :foreign_key => 'created_by'
  has_many :members, :class_name => 'Member',:dependent => :destroy
  has_and_belongs_to_many :trackers, :class_name => 'Tracker'
  has_many :versions, :class_name => 'Version'
  has_many :categories, :class_name => 'Category',:dependent => :destroy
  has_many :issues, :class_name => 'Issue',:dependent => :destroy
  has_many :attachments, :foreign_key => 'object_id', :conditions => {:object_type => self.to_s},:dependent => :destroy
  has_many :enabled_modules, :dependent => :destroy
  has_many :documents, :dependent => :destroy
  
  validates_associated :attachments
  validates :name, :identifier, :presence => true, :uniqueness => true
  validates :name, :length => {
    :maximum   => 255,
    :tokenizer => lambda { |str| str.scan(/\w+/) },
    :too_long  => 'must have at most 255 words'
  }

  def create_member
    role = Role.find_by_name('Project Manager')
    Member.create(:project_id => self.id, :role_id => role.id, :user_id => self.created_by)
  end
  
  def starred?
    members = self.members
    member = members.select{|member| member.user_id == User.current.id}.first
    return member.is_project_starred
  end
  
  def self.opened_projects_id
    return Project.select('id').where(:is_archived => false).collect{|p| p.id}
  end

  #ATTACHMENT METHODS
  def new_attachment_attributes=(attachment_attributes)
    attachment_attributes.each do |attributes|
      attributes['object_type'] = 'Project'
      attachments.build(attributes)
    end
  end

  def existing_attachment_attributes=(attachment_attributes)
    attachments.reject(&:new_record?).each do |attachment|
      attributes = attachment_attributes[attachment.id.to_s]
      if attributes
        attachment.attributes = attributes
      else
        attachment.delete
      end
    end
  end

  def save_attachments
    attachments.each do |attachment|
      attachment.save(:validation => false)
    end
  end
end
