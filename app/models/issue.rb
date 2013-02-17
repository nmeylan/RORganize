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
  has_many :checklist_items, :class_name => 'ChecklistItem', :dependent => :destroy
  has_many :attachments, :foreign_key => 'object_id', :conditions => {:object_type => self.to_s},:dependent => :destroy
  has_many :journals, :foreign_key => 'journalized_id',:class_name => 'Journal', :conditions => {:journalized_type => self.to_s}, :dependent => :destroy
  #  has_many :scenarios, :class_name => 'Scenario', :dependent => :destroy

  validates_associated :attachments

  validates :subject, :tracker_id, :status_id, :assigned_to_id, :presence => true
  validates :due_date, :format =>
  def self.paginated_issues(page, per_page, order, filter, project_id)
    paginate(:page => page,
      :include => [:tracker,:version,:status,:assigned_to,:category,:checklist_items, :attachments],
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
    if done_ratio != 0
      self.done = done_ratio
    end
  end

  def set_due_date
    if self.version && !self.version.target_date.nil? && self.version_id_changed?
      self.due_date = self.version.target_date
    end
  end
end

