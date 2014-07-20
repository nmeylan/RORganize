# Author: Nicolas Meylan
# Date: 06 avri. 2013
# Encoding: UTF-8
# File: document.rb
class Document < ActiveRecord::Base
  include Rorganize::JounalsManager
  include Rorganize::AbstractModelCaption
  include Rorganize::SmartRecords
  #Class variables
  assign_journalized_properties({name: 'Name', category_id: 'Category', version_id: 'Version'})
  assign_foreign_keys({category_id: Category, version_id: Version})
  #Relations
  belongs_to :version
  belongs_to :category
  has_many :attachments, -> { where :object_type => 'Document' }, :foreign_key => 'object_id', :dependent => :destroy
  belongs_to :project
  has_many :journals, -> { where :journalized_type => 'Document' }, :as => :journalized, :dependent => :destroy
  #Validators
  validates_associated :attachments
  validates :name, :presence => true
  #triggers
  after_update :save_attachments, :update_journal
  after_create :create_journal
  after_destroy :destroy_journal
  #Scopes
  scope :filtered, ->(filter, project_id) { where("#{filter} documents.project_id = #{project_id}").eager_load([:version, :category]) }
  #methods

  def caption
    self.name
  end

  def self.permit_attributes
    [:name, :description, :version_id, :category_id, {:new_attachment_attributes => Attachment.permit_attributes}, {:edit_attachment_attributes => Attachment.permit_attributes}]
  end

  def self.permit_bulk_edit_values
    [:version_id, :category_id]
  end

  #Attributes name without id
  def self.attributes_formalized_names
    names = []
    Document.attribute_names.each { |attribute| !attribute.eql?('id') ? names << attribute.gsub(/_id/, '').gsub(/id/, '').gsub(/_/, ' ').capitalize : '' }
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


  #Return an array with all attribute that can be filtered
  def self.filtered_attributes
    filtered_attributes = []
    unused_attributes = %w(Project Description)
    attrs = Document.attributes_formalized_names.delete_if { |attribute| unused_attributes.include?(attribute) }
    attrs.each { |attribute| filtered_attributes << [attribute, attribute.gsub(/\s/, '_').downcase] }
    return filtered_attributes
  end

  def self.bulk_edit(doc_ids, value_param)
    #Editing with toolbox
    documents_toolbox = Document.where(:id => doc_ids)

    #As form send all attributes, we drop all attributes except th filled one.
    value_param.delete_if { |k, v| v.eql?('') }
    key = value_param.keys[0]
    value = value_param.values[0]
    if value.eql?('-1')
      value_param[key] = nil
    end
    # Can't call Document.update_all because, after_update callback is not triggered :(
    Document.transaction do
      documents_toolbox.each do |document|
        document.attributes = value_param
        if document.changed?
          document.save
        end
      end
    end
  end

  def self.bulk_delete(doc_ids)
    documents_toolbox = Document.where(:id => doc_ids)
    # Can't call Document.delete_all because, after_delete and :depends destroy callback is not triggered :(
    Document.transaction do
      documents_toolbox.each do |document|
        document.destroy
      end
    end
  end

  def self.conditions_string(hash)
    #attributes from db: get real attribute name to build query
    table = self.table_name
    attributes = {
        'category' => table + '.category_id',
        'created_at' => table + '.created_at',
        'name' => table + '.name',
        'version' => table + '.version_id',
        'updated_at' => table + '.updated_at'
    }
    Rorganize::MagicFilter.generics_filter(hash, attributes)
  end
end
