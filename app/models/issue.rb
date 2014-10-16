# Author: Nicolas Meylan
# Date: 13 juil. 2012
# Encoding: UTF-8
# File: issue.rb
class Issue < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  include Rorganize::Models::Journalizable
  include Rorganize::Models::Commentable
  include Rorganize::Models::Watchable
  include Rorganize::Models::Notifiable
  include Rorganize::Models::Attachable::AttachmentType
  include Rorganize::Models::IssueExtraMethods
  extend Rorganize::Managers::BulkEditManager
  #Class variables
  exclude_attributes_from_journal(:description, :attachments_count, :link_type, :comments_count)
  attr_accessor :notes
  #Relations
  belongs_to :project, class_name: 'Project', counter_cache: true
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :assigned_to, class_name: 'User', foreign_key: 'assigned_to_id'
  belongs_to :version, class_name: 'Version', foreign_key: 'version_id'
  belongs_to :tracker, class_name: 'Tracker'
  belongs_to :status, class_name: 'IssuesStatus'
  belongs_to :category, class_name: 'Category'
  has_many :children, foreign_key: 'predecessor_id', class_name: 'Issue'
  belongs_to :parent, foreign_key: 'predecessor_id', class_name: 'Issue'
  has_many :time_entries, dependent: :destroy
  #triggers
  before_validation :set_start_and_due_date
  before_save :set_done_ratio
  after_update :save_attachments
  #Validators
  validates :subject, :tracker_id, :status_id, presence: true
  validate :validate_start_date, :validate_predecessor, :validate_due_date
  #Scopes
  scope :fetch_dependencies, -> { includes([:tracker, :version, :assigned_to, :category, :project, :attachments, :author, status: [:enumeration]]) }
  scope :opened_issues, -> { joins(:status).where('issues_statuses.is_closed = false') }
  #Group
  scope :group_opened_by_attr, -> (project_id, table_name, attr, conditions = '1 = 1') { joins(:project, :status).joins("LEFT OUTER JOIN #{table_name} ON #{table_name}.id = issues.#{attr}_id").group('1').where('issues_statuses.is_closed = false AND issues.project_id = ? AND ?', project_id, conditions).pluck("#{table_name}.id, #{table_name}.name, count(issues.id), projects.slug") }

  scope :group_by_status, -> (project_id) { joins(:project, status: [:enumeration]).group('1').where('issues.project_id = ?', project_id).pluck('issues_statuses.id, enumerations.name, count(issues.id), projects.slug') }

  scope :group_opened_by_project, -> (attr, conditions = '1 = 1') { joins(:project, status: [:enumeration]).group('2').where("issues_statuses.is_closed = false AND #{conditions}").pluck("#{attr}, projects.id, projects.slug, count(issues.id), projects.slug") }

  def caption
    self.subject
  end

  # @return [Array] array with all attribute that can be filtered.
  def self.filtered_attributes
    unused_attributes = ['Project', 'Description', 'Estimated time', 'Predecessor', 'Attachments count', 'Comments count', 'Link type']
    attrs = Issue.attributes_formalized_names.delete_if { |attribute| unused_attributes.include?(attribute) }
    attrs.map { |attribute| [attribute, attribute.gsub(/\s/, '_').downcase] }
  end

  def set_predecessor(predecessor_id)
    self.predecessor_id = predecessor_id
    saved = self.save
    journals = Journal.where(journalizable_type: 'Issue', journalizable_id: self.id).includes([:details, :user])
    {saved: saved, journals: journals}
  end

  # @param [Array] doc_ids : array containing all ids of issues that will be bulk edited.
  # @param [Hash] value_param : hash of {attribute: :new_value}.
  def self.bulk_edit(issue_ids, value_param, project)
    issues, journals = super(issue_ids, value_param, project)
    # If version changed trigger the due and start date rules.
    Issue.bulk_set_done_ratio(issue_ids, value_param[:status_id],journals) if value_param[:status_id]
    bulk_set_start_and_due_date(issues.collect { |issue| issue.id }, value_param[:version_id], journals) if value_param[:version_id]
  end

  # @param [Array] issue_ids : array containing all ids of issues that will be bulk deleted.
  def self.bulk_delete(issue_ids, project)
    destroyed_objects = super(issue_ids, project)
    Project.update_counters(project.id, issues_count: -destroyed_objects.size)
  end

  def self.conditions_string(hash)
    #attributes from db: get real attribute name to build query
    #noinspection RubyStringKeysInHashInspection,RubyStringKeysInHashInspection
    attributes = {'assigned_to' => 'issues.assigned_to_id',
                  'author' => 'issues.author_id',
                  'category' => 'issues.category_id',
                  'created_at' => 'issues.created_at',
                  'done' => 'issues.done',
                  'due_date' => 'issues.due_date',
                  'start_date' => 'issues.start_date',
                  'status' => 'issues.status_id',
                  'subject' => 'issues.subject',
                  'tracker' => 'issues.tracker_id',
                  'version' => 'issues.version_id',
                  'updated_at' => 'issues.updated_at'
    }
    hash.each do |_, v|
      if v['operator'].eql?('open')
        v['value'] = IssuesStatus.where(is_closed: 0).collect { |status| status.id }
      elsif v['operator'].eql?('close')
        v['value'] = IssuesStatus.where(is_closed: 1).collect { |status| status.id }
      end
    end
    Rorganize::MagicFilter.generics_filter(hash, attributes)
  end

  # @return [Boolean] true if issue has an opened status. false otherwise.
  def open?
    !self.status.is_closed
  end

  def has_task_list?
    self.description && !self.description.empty? && self.description.scan(/- \[(\w|\s)\]/).count > 0
  end

  def count_checked_tasks
    self.has_task_list? ? self.description.scan(/- \[x\]/).count : 0
  end

  def count_tasks
    self.has_task_list? ? self.description.scan(/- \[(\w|\s)\]/).count : 0
  end




  private
  def set_done_ratio
    unless self.status.nil?
      done_ratio = self.status.default_done_ratio
      if done_ratio != 0 && !self.done_changed?
        self.done = done_ratio
      end
    end
  end

  def self.bulk_set_done_ratio(issue_ids, status_id, journals)
    status = IssuesStatus.find_by_id(status_id)
    issues = Issue.where(id: issue_ids)
    issues.each do |issue|
      issue.done = status.default_done_ratio
    end
    issues.update_all(done: status.default_done_ratio)
    Issue.journal_update_creation(issues, issues.first.project, User.current.id, 'Issue', journals)
  end

  #Permit attributes
  def self.permit_attributes
    [:assigned_to_id, :author_id, :version_id, :done, :category_id, :status_id, :start_date, :subject, :description, :tracker_id, :due_date, :estimated_time, {new_attachment_attributes: Attachment.permit_attributes}, {edit_attachment_attributes: Attachment.permit_attributes}]
  end

  def self.permit_bulk_edit_values
    [:assigned_to_id, :author_id, :version_id, :done, :category_id, :status_id, :start_date]
  end
end

