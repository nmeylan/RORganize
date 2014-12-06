class Project < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  include Rorganize::Models::Attachable::AttachmentType
  include Rorganize::Models::Watchable
  include Rorganize::Managers::ModuleManager::ModuleManagerHelper
  #SLug
  extend FriendlyId
  friendly_id :name, use: :slugged
  #Relations
  has_many :issues, class_name: 'Issue', dependent: :delete_all
  has_many :enabled_modules, dependent: :delete_all
  has_many :documents, dependent: :delete_all
  belongs_to :author, class_name: 'User', foreign_key: 'created_by'
  has_many :members, class_name: 'Member', dependent: :delete_all
  has_and_belongs_to_many :trackers, class_name: 'Tracker'
  has_many :versions, class_name: 'Version', dependent: :delete_all
  has_many :categories, class_name: 'Category', dependent: :delete_all
  has_many :journals, dependent: :delete_all
  has_many :comments, dependent: :delete_all
  has_many :watchers, dependent: :delete_all
  has_many :notifications, dependent: :delete_all
  has_many :queries, dependent: :delete_all
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

  def should_generate_new_friendly_id?
    name_changed?
  end

  def caption
    self.slug
  end

  def self.journalizable_items
    Project.reflect_on_all_associations.map do |relation|
      find_relation_journalizable(relation)
    end.compact.flatten
  end

  def self.find_relation_journalizable(relation)
    if relation.macro.eql?(:has_one)
      sub_relation_lookup(relation).compact
    elsif relation.macro.eql?(:has_many)
      journalizable_item_class_name(relation)
    end
  end

  def self.sub_relation_lookup(relation)
    relation.klass.reflect_on_all_associations(:has_many).map do |sub_relation|
      journalizable_item_class_name(sub_relation)
    end
  end

  def self.journalizable_item_class_name(sub_relation)
    sub_relation.class_name if sub_relation.klass.included_modules.include?(Rorganize::Models::Journalizable)
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
    self.versions.where('versions.start_date <= ? AND versions.is_done = false', Date.today).includes(:issues)
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

  def non_member_users
    members = Member.eager_load(:user, :role).where(project_id: self.id)
    non_member_id = Role.non_member.id
    ids = members.collect { |member| member.user.id unless member.role_id.eql?(non_member_id) }
    User.where('users.id NOT IN (?)', ids.compact)
  end

  def remove_all_non_member
    if self.is_public_changed? && !self.is_public
      Member.destroy_all(project_id: self.id, role_id: Role.non_member.id)
      Watcher.delete_all("project_id = #{self.id} AND user_id NOT IN (#{self.members.collect { |member| member.user_id }.join(',')})")
    end
  end
end
