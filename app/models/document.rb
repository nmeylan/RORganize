# Author: Nicolas Meylan
# Date: 06 avri. 2013
# Encoding: UTF-8
# File: document.rb
class Document < ActiveRecord::Base
  include Rorganize::Journalizable
  include Rorganize::SmartRecords
  include Rorganize::Attachable::AttachmentType
  include Rorganize::Commentable
  #Class variables
  assign_journalizable_properties({name: 'Name', category_id: 'Category', version_id: 'Version'})
  assign_foreign_keys({category_id: Category, version_id: Version})
  #Relations
  belongs_to :version
  belongs_to :category
  belongs_to :project
  #Validators
  validates :name, :presence => true
  #triggers
  after_update :save_attachments
  #Scopes
  scope :fetch_dependencies, -> { eager_load([:version, :category]) }
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

  # @return [Array] all attributes except id.
  def self.attributes_formalized_names
    names = []
    Document.attribute_names.each { |attribute| !attribute.eql?('id') ? names << attribute.gsub(/_id/, '').gsub(/id/, '').gsub(/_/, ' ').capitalize : '' }
    return names
  end

  # @return [Array] with all attribute that can be filtered.
  def self.filtered_attributes
    filtered_attributes = []
    unused_attributes = %w(Project Description)
    attrs = Document.attributes_formalized_names.delete_if { |attribute| unused_attributes.include?(attribute) }
    attrs.each { |attribute| filtered_attributes << [attribute, attribute.gsub(/\s/, '_').downcase] }
    return filtered_attributes
  end

  # @param [Array] doc_ids : array containing all ids of documents that will be bulk edited.
  # @param [Hash] value_param : hash of attribute: :new_value.
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

  # @param [Array] doc_ids : array containing all ids of documents that will be bulk deleted.
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
