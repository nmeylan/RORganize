# Author: Nicolas Meylan
# Date: 06 avri. 2013
# Encoding: UTF-8
# File: document.rb
class Document < ActiveRecord::Base
  after_update :save_attachments

  belongs_to :version
  belongs_to :category
  has_many :attachments, :foreign_key => 'object_id', :conditions => {:object_type => self.to_s},:dependent => :destroy
  belongs_to :project
  has_many :journals, :as => :journalized,:conditions => {:journalized_type => self.to_s}, :dependent => :destroy
  validates_associated :attachments
  validates :name, :presence => true

  def self.paginated_documents(page, per_page, order, filter, project_id)
    paginate(:page => page,
      :include => [:version,:category, :attachments],
      :conditions => filter+" documents.project_id = #{project_id}",
      :per_page => per_page,
      :order => order)
  end

  #Attributes name without id
  def self.attributes_formalized_names
    names = []
    Document.attribute_names.each{|attribute| !attribute.eql?('id') ? names << attribute.gsub(/_id/,'').gsub(/id/,'').gsub(/_/,' ').capitalize : ''}
    return names
  end

  #ATTACHMENT METHODS
  def new_attachment_attributes=(attachment_attributes)
    attachment_attributes.each do |attributes|
      attributes['object_type'] = 'Document'
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
end
