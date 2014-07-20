# Author: Nicolas Meylan
# Date: 13 juil. 2012
# Encoding: UTF-8
# File: issue.rb
class Issue < ActiveRecord::Base
  include Rorganize::SmartRecords
  include Rorganize::JounalsManager
  #Class variables
  assign_journalized_properties({status_id: 'Status', category_id: 'Category', assigned_to_id: 'Assigned to', tracker_id: 'Tracker', due_date: 'Due date', start_date: 'Start date', done: 'Done', estimated_time: 'Estimated time', version_id: 'Version', predecessor_id: 'Predecessor'})
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
  has_many :checklist_items, :class_name => 'ChecklistItem', :dependent => :destroy
  has_many :attachments, -> { where :object_type => 'Issue' }, :foreign_key => 'object_id', :dependent => :destroy
  has_many :journals, -> { where :journalized_type => 'Issue' }, :as => :journalized, :dependent => :destroy
  has_many :time_entries, :dependent => :destroy
  #triggers
  before_save :set_done_ratio
  before_update :set_done_ratio, :set_due_date
  after_update :save_attachments, :update_journal
  after_create :create_journal
  after_destroy :destroy_journal
  #Validators
  validates_associated :attachments
  validates :subject, :tracker_id, :status_id, :presence => true
  validate :validate_start_date, :validate_predecessor
  #Scopes
  scope :fetch_dependencies, -> { eager_load([:tracker, :version, :assigned_to, :category, :attachments, :status => [:enumeration]]) }
  scope :assigned_issues_for_user, ->(user) { where(:assigned_to_id => user.id, :status_id => IssuesStatus.opened_statuses_id, :project_id => Project.opened_projects_id).eager_load(:project) }
  scope :submitted_issues_by_user, ->(user) { where(:author_id => user.id, :status_id => IssuesStatus.opened_statuses_id, :project_id => Project.opened_projects_id).eager_load(:project) }

  def caption
    self.subject
  end

  #Attributes name without id
  def self.attributes_formalized_names
    names = []
    Issue.attribute_names.each { |attribute| !attribute.eql?('id') ? names << attribute.gsub(/_id/, '').gsub(/id/, '').gsub(/_/, ' ').capitalize : '' }
    return names
  end

  #  Custom validator
  def validate_start_date
    unless (self.due_date && self.start_date) ? self.start_date <= self.due_date : true
      errors.add(:start_date, 'must be inferior than due date')
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

  #ATTACHMENT METHODS
  def new_attachment_attributes=(attachment_attributes)
    attachment_attributes.each do |attributes|
      attributes['object_type'] = 'Issue'
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

  #Return an array with all attribute that can be filtered
  def self.filtered_attributes
    filtered_attributes = []
    unused_attributes = ['Project', 'Description', 'Estimated time', 'Predecessor', 'Checklist items count', 'Attachments count']
    attrs = Issue.attributes_formalized_names.delete_if { |attribute| unused_attributes.include?(attribute) }
    attrs.each { |attribute| filtered_attributes << [attribute, attribute.gsub(/\s/, '_').downcase] } # TODO use map
    return filtered_attributes
  end

  def self.display_issue_object(issue_id, project)
    object = {}
    object[:issue] = Issue.eager_load([:tracker, :version, :assigned_to, :category, :attachments, :parent, :journals => [:details, :user]], status: [:enumeration]).where(id: issue_id)[0]
    object[:allowed_statuses] = User.current.allowed_statuses(project)
    object[:done_ratio] = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
    object[:checklist_statuses] = Enumeration.where(:opt => 'CLIS')
    object[:checklist_items] = ChecklistItem.where(:issue_id => issue_id).eager_load([:enumeration]).order(:position)
    object
  end

  def set_predecessor(predecessor_id)
    self.predecessor_id = predecessor_id
    saved = self.save
    journals = Journal.where(:journalized_type => 'Issue', :journalized_id => self.id).includes([:details, :user])
    {:saved => saved, :journals => journals}
  end


  def self.bulk_edit(issue_ids, value_param)
    issues_toolbox = Issue.where(:id => issue_ids).includes(:tracker, :version, :assigned_to, :category, :status => [:enumeration])
    #As form send all attributes, we drop all attributes except th filled one.
    value_param.delete_if { |k, v| v.eql?('') }
    key = value_param.keys[0]
    value = value_param.values[0]
    if value.eql?('-1')
      value_param[key] = nil
    end
    Issue.transaction do
      issues_toolbox.each do |issue|
        issue.attributes = value_param
        if issue.changed?
          issue.save
        end
      end
    end
  end

  def self.bulk_delete(issue_ids)
    issues = Issue.where(:id => issue_ids)
    Issue.transaction do
      issues.each do |issue|
        if issue.author_id.eql?(User.current.id) || User.current.allowed_to?('delete not owner', 'Issue', @project)
          issue.destroy
        end
      end
    end
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

  private
  def set_done_ratio
    unless self.status.nil?
      done_ratio = self.status.default_done_ratio
      if done_ratio != 0 && !self.done_changed?
        self.done = done_ratio
      end
    end
  end

  def set_due_date
    if self.version && !self.version.target_date.nil? && self.version_id_changed?
      self.due_date = self.version.target_date
    end
  end

  #Permit attributes
  def self.permit_attributes
    [:assigned_to_id, :author_id, :version_id, :done, :category_id, :status_id, :start_date, :subject, :description, :tracker_id, :due_date, :estimated_time, {:new_attachment_attributes => Attachment.permit_attributes}, {:edit_attachment_attributes => Attachment.permit_attributes}]
  end

  def self.permit_bulk_edit_values
    [:assigned_to_id, :author_id, :version_id, :done, :category_id, :status_id, :start_date]
  end
end

