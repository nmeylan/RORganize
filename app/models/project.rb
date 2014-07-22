class Project < ActiveRecord::Base
  include Rorganize::SmartRecords
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
  has_many :attachments, -> { where :object_type => 'Project' }, :foreign_key => 'object_id', :dependent => :destroy
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

  def caption
    self.slug
  end

  def self.permit_attributes
    [:name, :description, :identifier, :trackers, :new_attachment_attributes => Attachment.permit_attributes, :existing_attachment_attributes => Attachment.permit_attributes]
  end

  def create_member
    role = Role.find_by_name('Project Manager')
    Member.create(:project_id => self.id, :role_id => role.id, :user_id => self.created_by)
  end

  def starred?
    members = self.members
    member = members.to_a.select { |member| member.user_id == User.current.id }.first
    member.is_project_starred
  end

  def self.opened_projects_id
    return Project.where(:is_archived => false).pluck('id')
  end

  #Build an array containing project issues activities and misc activities
  def activities(journalized_types)
    activity_hash = Hash.new { |h, k| h[k] = [] }
    Journal.activities(journalized_types, "project_id = #{self.id}").each do |journal|
      date = journal.created_at.to_date.strftime("%a. %-d %b.")
      activity_hash[date][journal.journalized_id] ||= []
      activity_hash[date][journal.journalized_id] << journal
    end
    activity_hash
  end

  def update_info(params, trackers)
    self.attributes = params
    self.trackers.clear
    unless trackers.nil?
      tracker_ids = trackers.values
      trackers = Tracker.where(:id => tracker_ids)
      tracker_ids.each do |id|
        tracker = trackers.select { |track| track.id == id.to_i }
        self.trackers << tracker
      end
    end
    self.save
  end

  def last_activity
    self.journals.order("#{:created_at} desc").limit(1).first
  end

  def done_version

  end

  def active_versions
    self.versions.where(is_done: false)
  end

  def current_versions
    self.versions.where('start_date <= ? AND is_done = false', Date.today)
  end

  def roadmap
    structure = Hash.new { |k, v| k[v] = {} }
    versions_overviews = Version.overviews(self.id)
    issues_array = Issue.eager_load(:status, :tracker).includes(:version).where(project_id: self.id).to_a
    versions_overviews.each do |version_overview|
      structure[version_overview.first] = {
          percent: version_overview[3], closed_issues_count: version_overview[2], opened_issues_count: version_overview[1], issues: issues_array.select { |issue| issue.version_id.eql?(version_overview.first) }
      }
    end
    structure
  end
end
