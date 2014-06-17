class Project < ActiveRecord::Base
  #SLug
  extend FriendlyId
  friendly_id :identifier, use: :slugged
  after_create :create_member
  after_update :save_attachments

  belongs_to :author, :class_name => 'User', :foreign_key => 'created_by'
  has_many :members, :class_name => 'Member', :dependent => :destroy
  has_and_belongs_to_many :trackers, :class_name => 'Tracker'
  has_many :versions, :class_name => 'Version'
  has_many :categories, :class_name => 'Category', :dependent => :destroy
  has_many :issues, :class_name => 'Issue', :dependent => :destroy
  has_many :attachments, -> {where :object_type => 'Project'}, :foreign_key => 'object_id', :dependent => :destroy
  has_many :enabled_modules, :dependent => :destroy
  has_many :documents, :dependent => :destroy
  has_many :journals, :dependent => :destroy

  validates_associated :attachments
  validates :name, :identifier, :presence => true, :uniqueness => true
  validates :name, :length => {
      :maximum => 255,
      :tokenizer => lambda { |str| str.scan(/\w+/) },
      :too_long => 'must have at most 255 words'
  }

  def self.permit_attributes
    [:name, :description, :identifier, :new_attachment_attributes => Attachment.permit_attributes, :existing_attachment_attributes => Attachment.permit_attributes]
  end

  def create_member
    role = Role.find_by_name('Project Manager')
    Member.create(:project_id => self.id, :role_id => role.id, :user_id => self.created_by)
  end

  def starred?
    members = self.members
    member = members.select { |member| member.user_id == User.current.id }.first
    member.is_project_starred
  end

  def self.opened_projects_id
    return Project.select('id').where(:is_archived => false).collect { |p| p.id }
  end

  #ATTACHMENT METHODS
  def new_attachment_attributes=(attachment_attributes)
    attachment_attributes.each do |attributes|
      attributes['object_type'] = self.class.name
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

  #Build an ary containing project issues activities and misc activities
  def activities(filter)
    #Structure of the hash is
    # {:date => [journal]}
    issue_activities = Hash.new { |hash, key| hash[key] = [] }
    journals =(
    filter[0].eql?('all') ?
        Journal.includes([:journalized,:details, :user, :project, :issue => [:tracker]]).where(:project_id => self.id).order('journals.created_at DESC') :
        Journal.includes([:journalized, :details, :user, :project, :issue => [:tracker]]).where(['journals.project_id = ? AND journals.created_at > ?', self.id,
                                                                                                  filter[0]]).order('journals.created_at DESC')
    )
    activities = Hash.new { |hash, key| hash[key] = [] }
    journals.each do |journal|
      if journal.journalized_type.eql?('Issue')
        issue_activities[journal.created_at.to_formatted_s(:db).to_date.to_s] << journal
      else
        activities[journal.created_at.to_date.to_s] << journal
      end
    end
    issue_activities.values.each { |ary| ary.uniq! { |act| act.journalized_id } }
    [issue_activities,  activities]
  end

  #Return a member hash for project overview
  def members_overview
    members = Member.where(:project_id => self.id).includes([:user])
    roles = Role.all
    members_hash = Hash.new { |h, k| h[k] = [] }
    roles.each { |role| members_hash[role.name] = members.select { |member| member.role_id == role.id } }
    members_hash
  end

  def update_info(params, trackers)
    self.attributes = params
    tracker_ids = trackers.values
    trackers = Tracker.where(:id => tracker_ids)
    self.trackers.clear
    tracker_ids.each do |id|
      tracker = trackers.select{|track| track.id == id.to_i }
      self.trackers << tracker
    end
    self.save
  end

  def last_activity
    self.journals.order("#{:created_at} desc").limit(1).first
  end
end
