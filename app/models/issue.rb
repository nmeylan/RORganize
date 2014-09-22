# Author: Nicolas Meylan
# Date: 13 juil. 2012
# Encoding: UTF-8
# File: issue.rb
class Issue < ActiveRecord::Base
  include Rorganize::SmartRecords
  include Rorganize::Journalizable
  include Rorganize::Commentable
  include Rorganize::Watchable
  include Rorganize::Notifiable
  include Rorganize::Attachable::AttachmentType
  extend Rorganize::BulkEditManager
  #Class variables
  assign_journalizable_properties({status_id: 'Status', category_id: 'Category', assigned_to_id: 'Assigned to', tracker_id: 'Tracker', due_date: 'Due date', start_date: 'Start date', done: 'Done', estimated_time: 'Estimated time', version_id: 'Version', predecessor_id: 'Predecessor', subject: 'Subject'})
  assign_foreign_keys({status_id: IssuesStatus, category_id: Category, assigned_to_id: User, tracker_id: Tracker, version_id: Version})
  attr_accessor :notes
  #Relations
  belongs_to :project, :class_name => 'Project', counter_cache: true
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :assigned_to, :class_name => 'User', :foreign_key => 'assigned_to_id'
  belongs_to :version, :class_name => 'Version', :foreign_key => 'version_id', :counter_cache => true
  belongs_to :tracker, :class_name => 'Tracker'
  belongs_to :status, :class_name => 'IssuesStatus'
  belongs_to :category, :class_name => 'Category'
  has_many :children, :foreign_key => 'predecessor_id', :class_name => 'Issue'
  belongs_to :parent, :foreign_key => 'predecessor_id', :class_name => 'Issue'
  has_many :time_entries, :dependent => :destroy
  #triggers
  before_validation :set_start_and_due_date
  before_save :set_done_ratio
  before_update :set_done_ratio
  after_update :save_attachments
  #Validators
  validates :subject, :tracker_id, :status_id, :presence => true
  validate :validate_start_date, :validate_predecessor, :validate_due_date
  #Scopes
  scope :fetch_dependencies, -> { includes([:tracker, :version, :assigned_to, :category, :project, :attachments, :author, :status => [:enumeration]]) }
  scope :opened_issues, -> { joins(:status).where('issues_statuses.is_closed = false') }
  #Group
  scope :group_opened_by_attr, -> (project_id, table_name, attr, conditions = '1 = 1') { joins(:project, :status).joins("LEFT OUTER JOIN #{table_name} ON #{table_name}.id = issues.#{attr}_id").group('1').where('issues_statuses.is_closed = false AND issues.project_id = ? AND ?', project_id, conditions).pluck("#{table_name}.id, #{table_name}.name, count(issues.id), projects.slug") }

  scope :group_by_status, -> (project_id) { joins(:project, status: [:enumeration]).group('1').where('issues.project_id = ?', project_id).pluck("issues_statuses.id, enumerations.name, count(issues.id), projects.slug") }

  scope :group_opened_by_project, -> (attr, conditions = '1 = 1') { joins(:project, status: [:enumeration]).group('2').where("issues_statuses.is_closed = false AND #{conditions}").pluck("#{attr}, projects.id, projects.slug, count(issues.id), projects.slug") }

  def caption
    self.subject
  end

  #Attributes name without id
  def self.attributes_formalized_names
    Issue.attribute_names.map { |attribute| attribute.gsub(/_id/, '').gsub(/id/, '').gsub(/_/, ' ').capitalize unless attribute.eql?('id') }.compact
  end

  #  Custom validator
  def validate_start_date
    if (self.due_date && self.start_date) && self.start_date >= self.due_date
      errors.add(:start_date, "must be inferior than due date : #{self.due_date.to_formatted_s(:db)}")
    elsif (self.start_date && self.version && self.version.target_date) && self.start_date >= self.version.target_date
      errors.add(:start_date, "must be inferior than version due date : #{self.version.target_date.to_formatted_s(:db)}")
    elsif (self.start_date && self.version) && self.start_date < self.version.start_date
      errors.add(:start_date, "must be superior or equal to version start date : #{self.version.start_date.to_formatted_s(:db)}")
    end
  end

  def validate_due_date
    if (self.due_date && self.version && self.version.target_date) && self.due_date > self.version.target_date
      errors.add(:due_date, "must be inferior or equals to version due date : #{self.version.target_date.to_formatted_s(:db)}")
    elsif (self.due_date && self.version && self.version.start_date) && self.due_date <= self.version.start_date
      errors.add(:due_date, "must be superior than version start date : #{self.version.start_date.to_formatted_s(:db)}")
    end
  end

  def validate_predecessor
    unless self.predecessor_id.nil?
      issue = Issue.find(self.predecessor_id)
      if !issue.nil? && !issue.project_id.eql?(self.project_id) || issue.nil?
        errors.add(:predecessor, 'not exist in this project')
      elsif !issue.nil? && issue.id.eql?(self.id)
        errors.add(:predecessor, "can't be self")
      elsif !issue.nil? && self.children.include?(issue)
        errors.add(:predecessor, 'is already a child')
      end
    end
  rescue
    errors.add(:predecessor, 'not found')
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
    journals = Journal.where(:journalizable_type => 'Issue', :journalizable_id => self.id).includes([:details, :user])
    {:saved => saved, :journals => journals}
  end

  # @param [Array] doc_ids : array containing all ids of issues that will be bulk edited.
  # @param [Hash] value_param : hash of attribute: :new_value.
  def self.bulk_edit(issue_ids, value_param)
    issues_toolbox = Issue.where(:id => issue_ids).includes(:tracker, :version, :assigned_to, :category, :status => [:enumeration])
    #As form send all attributes, we drop all attributes except th filled one.
    value_param.delete_if { |k, v| v.eql?('') }
    key = value_param.keys[0]
    value = value_param.values[0]
    if value.eql?('-1')
      value_param[key] = nil
    end
    issues = []
    issues_toolbox.each do |issue|
      issue.attributes = value_param
      if issue.changed?
        issues << issue
      end
    end
    Issue.where(id: issues.collect { |issue| issue.id }).update_all(value_param)
    journals = journal_update_creation(issues, issues[0].project_id, User.current.id, 'Issue') if issues[0]
    Issue.bulk_set_start_and_due_date(issues.collect { |issue| issue.id }, value_param[:version_id], journals) if value_param[:version_id]

  end

  # @param [Hash] hash containing {issue_id: {attribute: new_value}}
  def self.gantt_edit(hash)
    errors = []
    Issue.transaction do
      hash.each do |k, v|
        issue = Issue.find_by_id(k)
        if issue
          issue.attributes = v
          if issue.changed?
            issue.save
            errors << issue.errors.messages if issue.errors.messages.any?
          end
        end
      end
      errors
    end
  end

  # @param [Array] doc_ids : array containing all ids of documents that will be bulk deleted.
  def self.bulk_delete(issue_ids, project)
    issues_toolbox = Issue.where(:id => issue_ids)
    issues = []
    ids = []
    issues_toolbox.each do |issue|
      if issue.author_id.eql?(User.current.id) || User.current.allowed_to?('destroy_not_owner', 'Issues', project)
        ids << issue.id
        issues << issue
      end
    end
    Issue.delete_all(id: ids)
    journal_delete_creation(issues, project.id, User.current.id, 'Issue')
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
        v['value'] = IssuesStatus.where(:is_closed => 0).collect { |status| status.id }
      elsif v['operator'].eql?('close')
        v['value'] = IssuesStatus.where(:is_closed => 1).collect { |status| status.id }
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

  # Set start date and due date based on version.
  # Rule :
  # Version.start_date <= Issue.start_date < Issue.due_date <= Version.due_date
  # So when issue's version is changing we have to update issue start and due date to respect the previous rule.
  def set_start_and_due_date
    if self.version && !self.version.target_date.nil? && self.version_id_changed?
      self.due_date = self.version.target_date
    end
    if self.version && self.version.start_date && self.version_id_changed? && (self.start_date.nil? || (self.start_date && (self.start_date < self.version.start_date) || self.version.target_date && self.start_date > self.version.target_date))
      self.start_date = self.version.start_date
    end
  end

  #TODO refactor this. Rework the rule
  def self.bulk_set_start_and_due_date(issue_ids, version_id, journals)
    journals_hash = {}
    journals.each do |journal|
      journals_hash[journal.journalizable_id] = journal
    end
    version = Version.find_by_id(version_id)
    issues = Issue.where(version_id: version.id, id: issue_ids)
    issues[0].due_date = version.target_date
    issues.update_all(due_date: version.target_date) if version.target_date
    j = []
    issues.each do |issue|
      j << journals_hash[issue.id]
    end

    journal_detail_insertion(j, issues[0])
    condition = version.target_date ? "issues.start_date > #{version.target_date}" : '1 <> 1'
    issues = issues.where("(issues.start_date IS NULL OR (issues.start_date < ? OR #{condition}))", version.start_date)
    issues.update_all(due_date: version.target_date)

    issues[0].due_date = version.target_date
    j = []
    issues.each do |issue|
      j << journals_hash[issue.id]
    end
    journal_detail_insertion(j, issues[0])
  end

  #Permit attributes
  def self.permit_attributes
    [:assigned_to_id, :author_id, :version_id, :done, :category_id, :status_id, :start_date, :subject, :description, :tracker_id, :due_date, :estimated_time, {:new_attachment_attributes => Attachment.permit_attributes}, {:edit_attachment_attributes => Attachment.permit_attributes}]
  end

  def self.permit_bulk_edit_values
    [:assigned_to_id, :author_id, :version_id, :done, :category_id, :status_id, :start_date]
  end
end

