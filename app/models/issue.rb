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
  #lib/rorganize/models/issues
  # Contains date validator and Gantt behaviour
  include Rorganize::Models::IssueExtraMethods
  extend Rorganize::Models::BulkEditable
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
  scope :fetch_dependencies, -> { fetch_dependencies_method }

  scope :prepare_paginated, -> (current_page, per_page, order, filter, project_id) {
    paginated_issues_method(current_page, filter, order, per_page, project_id)
  }
  scope :opened_issues, -> { joins(:status).where('issues_statuses.is_closed = false') }
  #Group
  scope :group_opened_by_attr, -> (project_id, table_name, attr, conditions = '1 = 1') {
    group_opened_by_attr_method(attr, conditions, project_id, table_name)
  }
  scope :group_by_status, -> (project_id) { group_by_status_method(project_id) }
  scope :group_opened_by_project, -> (attr, conditions = '1 = 1') { group_opened_by_project_method(attr, conditions) }

  # Scopes methods
  def self.fetch_dependencies_method
    includes([:tracker, :version, :assigned_to, :category, :project, :attachments, :author, status: [:enumeration]])
  end

  def self.paginated_issues_method(current_page, filter, order, per_page, project_id)
    filter(filter, project_id).paginated(current_page, per_page, order, [:tracker, :version, :assigned_to, :category, :project, :attachments, :author, status: [:enumeration]])
  end

  # @param [Numeric] project_id
  # @return [Array] an array with the following structure : [[status_id, status_name, size_of_the_group, project_slug], ..]
  # (e.g : [[4, 'Fixed to test', 3, 'test-project'], [5, 'Tested to be delivered', 1, 'test-project']])
  def self.group_by_status_method(project_id)
    joins(:project, status: [:enumeration]).
        group('1').
        where('issues.project_id = ?', project_id).
        pluck('issues_statuses.id, enumerations.name, count(issues.id), projects.slug')
  end

  # @param [String] attribute_name : the name of the attribute to group by.
  # @param [String] conditions : an extra condition string.
  # @param [Numeric] project_id : the project id.
  # @param [String] table_name : the table name of the attribute.
  # @return [Array] an array with the following structure : [[id, name, size_of_the_group, project_slug], ..]
  def self.group_opened_by_attr_method(attribute_name, conditions, project_id, table_name)
    joins(:project, :status).
        joins("LEFT OUTER JOIN #{table_name} ON #{table_name}.id = issues.#{attribute_name}_id").
        group('1').
        where('issues_statuses.is_closed = false AND issues.project_id = ? AND ?', project_id, conditions).
        pluck("#{table_name}.id, #{table_name}.name, count(issues.id), projects.slug")
  end

  # @param [String] database_field : e.g 'issues.assigned_to_id', 'issues.author_id'.
  # @param [String] conditions : a condition string e.g  'issues.assigned_to_id = 1'
  # @return [Array] an array with the following structure :
  # [[database_field_value, project_id, project_slug, size_of_the_group, project_slug], ..]
  def self.group_opened_by_project_method(database_field, conditions)
    joins(:project, status: [:enumeration]).
        group('2').
        where("issues_statuses.is_closed = false AND #{conditions}").
        pluck("#{database_field}, projects.id, projects.slug, count(issues.id), projects.slug")
  end

  # Methods
  def caption
    self.subject
  end

  # @return [Array] array with all attribute that can be filtered.
  def self.filtered_attributes
    unused_attributes = ['Project', 'Description', 'Estimated time', 'Predecessor',
                         'Attachments count', 'Comments count', 'Link type']
    attrs = Issue.attributes_formalized_names.delete_if { |attribute| unused_attributes.include?(attribute) }
    attrs.map { |attribute| [attribute, attribute.gsub(/\s/, '_').downcase] }
  end

  # @param [Array] doc_ids : array containing all ids of issues that will be bulk edited.
  # @param [Hash] value_param : hash of {attribute: :new_value}.
  def self.bulk_edit(issue_ids, value_param, project)
    issues, journals = super(issue_ids, value_param, project)
    # If version changed trigger the due and start date rules.
    Issue.bulk_set_done_ratio(issue_ids, value_param[:status_id], journals) if value_param[:status_id]
    bulk_set_start_and_due_date(issues.collect { |issue| issue.id }, value_param[:version_id], journals) if value_param[:version_id]
  end

  # @param [Array] issue_ids : array containing all ids of issues that will be bulk deleted.
  def self.bulk_delete(issue_ids, project)
    destroyed_objects = super(issue_ids, project)
    Project.update_counters(project.id, issues_count: -destroyed_objects.size)
  end

  #@param [Hash] criteria_hash : a hash with the following structure
  # {attribute_name:String => {"operator"=> String, "value"=> String}}
  # attribute_name is the name of the attribute on which criterion is based
  # E.g : {"subject"=>{"operator"=>"contains", "value"=>"test"}}
  # operator values are :
  # 'equal'
  # 'different'
  # 'superior'
  # 'inferior'
  # 'contains'
  # 'not_contains'
  # 'today'
  # 'open'
  # 'close'
  # @return [String] a condition string that will be used in a where clause.
  def self.conditions_string(criteria_hash)
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
    criteria_hash.each do |_, v|
      if v['operator'].eql?('open')
        v['value'] = IssuesStatus.where(is_closed: 0).collect { |status| status.id }
      elsif v['operator'].eql?('close')
        v['value'] = IssuesStatus.where(is_closed: 1).collect { |status| status.id }
      end
    end
    Rorganize::MagicFilter.generics_filter(criteria_hash, attributes)
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


  #Permit attributes
  def self.permit_attributes
    [:assigned_to_id, :author_id, :version_id, :done, :category_id, :status_id,
     :start_date, :subject, :description, :tracker_id, :due_date, :estimated_time,
     {new_attachment_attributes: Attachment.permit_attributes},
     {edit_attachment_attributes: Attachment.permit_attributes}]
  end

  def self.permit_bulk_edit_values
    [:assigned_to_id, :author_id, :version_id, :done, :category_id, :status_id, :start_date]
  end

  private
  def set_done_ratio
    if new_record_and_done_ratio_nil?
      self.done = 0
    elsif !self.status.nil?
      done_ratio = self.status.default_done_ratio
      if self.status_id_changed? && done_ratio && !self.done_changed?
        self.done = done_ratio
      end
    end
  end

  def new_record_and_done_ratio_nil?
    self.new_record? && self.done.nil? && self.status && self.status.default_done_ratio.nil?
  end

  def self.bulk_set_done_ratio(issue_ids, status_id, journals)
    status = IssuesStatus.find_by_id(status_id)
    done_ratio = status.default_done_ratio
    if done_ratio
      issues = Issue.where(id: issue_ids)
      issues.each do |issue|
        issue.done = status.default_done_ratio
      end
      issues.update_all(done: status.default_done_ratio)
      Issue.journal_update_creation(issues, issues.first.project, User.current.id, 'Issue', journals)
    end
  end
end

