# Author: Nicolas Meylan
# Date: 13 juil. 2012
# Encoding: UTF-8
# File: issue.rb

class Issue < ActiveRecord::Base
  before_save :set_done_ratio
  before_update :set_done_ratio, :set_due_date
  after_update :save_attachments
  belongs_to :project, :class_name => 'Project'
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :assigned_to, :class_name => 'User', :foreign_key => 'assigned_to_id'
  belongs_to :version, :class_name => 'Version', :foreign_key => 'version_id'
  belongs_to :tracker, :class_name => 'Tracker'
  belongs_to :status, :class_name => 'IssuesStatus', :include => [:enumeration]
  belongs_to :category, :class_name => 'Category'
  has_many :children, :foreign_key => 'predecessor_id', :class_name => 'Issue'
  belongs_to :parent, :foreign_key => 'predecessor_id', :class_name => 'Issue'
  has_many :checklist_items, :class_name => 'ChecklistItem', :dependent => :destroy
  has_many :attachments, :foreign_key => 'object_id', :conditions => {:object_type => self.to_s},:dependent => :destroy
  has_many :journals, :as => :journalized,:conditions => {:journalized_type => self.to_s}, :dependent => :destroy
  #  has_many :scenarios, :class_name => 'Scenario', :dependent => :destroy

  validates_associated :attachments

  validates :subject, :tracker_id, :status_id,:presence => true
  validate :validate_start_date, :validate_predecessor
  #  validates :due_date, :format =>
  def self.paginated_issues(page, per_page, order, filter, project_id)
    paginate(:page => page,
      :include => [:tracker,:version,:assigned_to,:category,:checklist_items, :attachments, :status => [:enumeration]],
      :conditions => filter+" issues.project_id = #{project_id}",
      :per_page => per_page,
      :order => order)

  end
  #Attributes name without id
  def self.attributes_formalized_names
    names = []
    Issue.attribute_names.each{|attribute| !attribute.eql?('id') ? names << attribute.gsub(/_id/,'').gsub(/id/,'').gsub(/_/,' ').capitalize : ''}
    return names
  end
  #  Custom validator
  def validate_start_date
    if !((self.due_date && self.start_date) ? self.start_date <= self.due_date : true)
      errors.add(:start_date,"must be inferior than due date")
    end
  end

  def validate_predecessor
    if !self.predecessor_id.nil?
      issue = Issue.find(self.predecessor_id)
      if !issue.nil? && !issue.project_id.eql?(self.project_id) || issue.nil?
        errors.add(:predecessor,"not exist in this project")
      elsif !issue.nil? && issue.id.eql?(self.id)
        errors.add(:predecessor,"can't be self")
      elsif !issue.nil? && self.children.include?(issue)
        errors.add(:predecessor,"is already a child")
      end
    end
  rescue
    errors.add(:predecessor,"not found")
  end

  def self.filter(hash)

    return Issue.find(:all,:conditions => query_str)
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

  private
  def set_done_ratio
    done_ratio = self.status.default_done_ratio
    if done_ratio != 0 && !self.done_changed?
      self.done = done_ratio
    end
  end

  def set_due_date
    if self.version && !self.version.target_date.nil? && self.version_id_changed?
      self.due_date = self.version.target_date
    end
  end
end

