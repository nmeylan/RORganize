class Project < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  include Rorganize::Models::Attachable::AttachmentType
  include Rorganize::Models::Watchable
  include Rorganize::Managers::ModuleManager::ModuleManagerHelper
  #SLug
  extend FriendlyId
  friendly_id :name, use: :slugged
  #Constants
  JOURNALIZABLE_ITEMS = %w(Issue Category Member Document Version Wiki WikiPage)
  #Relations
  belongs_to :author, class_name: 'User', foreign_key: 'created_by'
  has_many :members, class_name: 'Member', dependent: :destroy
  has_and_belongs_to_many :trackers, class_name: 'Tracker'
  has_many :versions, class_name: 'Version'
  has_many :categories, class_name: 'Category', dependent: :destroy
  has_many :issues, class_name: 'Issue', dependent: :destroy
  has_many :enabled_modules, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :journals, dependent: :destroy
  has_one :wiki
  #Triggers
  before_create :set_created_by
  after_create :create_member, :add_modules
  after_update :save_attachments, :remove_all_non_member
  #Validators
  validates_associated :attachments
  validates :name, presence: true, uniqueness: true
  validates :name, length: {
      maximum: 90,
      tokenizer: lambda { |str| str.scan(/\w+/) },
      too_long: 'must have at most 255 words'
  }

  def caption
    self.slug
  end

  def self.permit_attributes
    [:name, :description, :identifier, :trackers, :is_public, new_attachment_attributes: Attachment.permit_attributes, existing_attachment_attributes: Attachment.permit_attributes]
  end

  def set_created_by
    self.created_by = User.current.id
  end

  def create_member
    role = Role.find_by_name('Project Manager')
    Member.create(project_id: self.id, role_id: role.id, user_id: self.created_by)
  end

  def add_modules
    Rorganize::Managers::ModuleManager::enabled_by_default_modules.each do |m|
      self.enabled_modules << EnabledModule.new(m)
    end
    self.save
    reload_enabled_module(self.id)
  end

  def starred?
    members = self.members
    member = members.to_a.select { |member| member.user_id == User.current.id }.first
    member ? member.is_project_starred : false
  end

  def self.opened_projects_id
    return Project.where(is_archived: false).pluck('id')
  end

  def activities(journalizable_types, period, from_date)
    Journal.activities_eager_load(journalizable_types, period, from_date, "journals.project_id = #{self.id}")
  end

  def comments(journalizable_types, period, from_date)
    Comment.comments_eager_load(journalizable_types, period, from_date, "comments.project_id = #{self.id}")
  end

  def update_info(params, trackers)
    self.attributes = params
    self.trackers.clear
    unless trackers.nil?
      tracker_ids = trackers.values
      trackers = Tracker.where(id: tracker_ids)
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
    self.versions.where('versions.start_date <= ? AND versions.is_done = false', Date.today)
  end

  def old_versions
    self.versions.where('versions.start_date <= ? AND versions.is_done = true', Date.today)
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

  def real_members
    non_member = Role.non_member
    self.members.collect { |member| member unless member.role_id.eql?(non_member.id) }.compact
  end

  def remove_all_non_member
    if self.is_public_changed? && !self.is_public
      Member.destroy_all(project_id: self.id, role_id: Role.non_member.id)
      Watcher.delete_all("project_id = #{self.id} AND user_id NOT IN (#{self.members.collect { |member| member.user_id }.join(',')})")
    end
  end
end
