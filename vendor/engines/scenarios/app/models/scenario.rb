# Author: Nicolas Meylan
# Date: 8 déc. 2012
# Encoding: UTF-8
# File: scenarios.rb

class Scenario < ActiveRecord::Base

  after_update :save_attachments
  belongs_to :version, :class_name => 'Version'
  belongs_to :actor, :class_name => 'Enumeration'
  has_many :steps, :class_name => 'Step', :dependent => :destroy
  has_many :attachments, :foreign_key => 'object_id', :dependent => :destroy

  validates :name, :presence => true

  def self.paginated_scenarios(page, per_page, order, filter, project_id)
    paginate(:page => page,
      :include => [:actor,:version,:steps],
      :conditions => " scenarios.project_id = #{project_id}",
      :per_page => per_page,
      :order => order)
  end
   #ATTACHMENT METHODS
  def new_attachment_attributes=(attachment_attributes)
    attachment_attributes.each do |attributes|
      attributes['object_type'] = 'Scenario'
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
