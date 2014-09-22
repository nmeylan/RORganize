# Author: Nicolas Meylan
# Date: 06 avri. 2013
# Encoding: UTF-8
# File: document.rb
class Document < ActiveRecord::Base
  include Rorganize::Journalizable
  include Rorganize::SmartRecords
  include Rorganize::Attachable::AttachmentType
  include Rorganize::Commentable
  include Rorganize::Watchable
  include Rorganize::Notifiable
  extend Rorganize::BulkEditManager
  #Class variables
  assign_journalizable_properties({name: 'Name', category_id: 'Category', version_id: 'Version'})
  assign_foreign_keys({category_id: Category, version_id: Version})
  #Relations
  belongs_to :version
  belongs_to :category
  belongs_to :project
  #Validators
  validates :name, :presence => true, :length => 2..255
  #triggers
  after_update :save_attachments
  #Scopes
  scope :fetch_dependencies, -> { eager_load([:version, :category]) }
  #methods

  def caption
    self.name
  end

  def author
    Journal.find_by_action_type_and_journalizable_id_and_journalizable_type('created', self.id, self.class.to_s).user
  end

  def self.permit_attributes
    [:name, :description, :version_id, :category_id, {:new_attachment_attributes => Attachment.permit_attributes}, {:edit_attachment_attributes => Attachment.permit_attributes}]
  end

  def self.permit_bulk_edit_values
    [:version_id, :category_id]
  end

  # @return [Array] all attributes except id.
  def self.attributes_formalized_names
    Document.attribute_names.map { |attribute| attribute.gsub(/_id/, '').gsub(/id/, '').gsub(/_/, ' ').capitalize unless attribute.eql?('id')}.compact
  end

  # @return [Array] with all attribute that can be filtered.
  def self.filtered_attributes
    unused_attributes = %w(Project Description)
    attrs = Document.attributes_formalized_names.delete_if { |attribute| unused_attributes.include?(attribute) }
    attrs.map { |attribute| [attribute, attribute.gsub(/\s/, '_').downcase] }
  end

  # @param [Array] doc_ids : array containing all ids of documents that will be bulk edited.
  # @param [Hash] value_param : hash of attribute: :new_value.
  def self.bulk_edit(doc_ids, value_param)
    #Editing with toolbox
    documents_toolbox = Document.where(:id => doc_ids)
    documents = []
    #As form send all attributes, we drop all attributes except th filled one.
    value_param.delete_if { |k, v| v.eql?('') }
    key = value_param.keys[0]
    value = value_param.values[0]
    if value.eql?('-1')
      value_param[key] = nil
    end
    Document.transaction do
      documents_toolbox.each do |document|
        document.attributes = value_param
        if document.changed?
          documents << document
        end
      end
    end
    Document.where(id: documents.collect{|document| document.id}).update_all(value_param)
    journal_update_creation(documents, documents[0].project_id, User.current.id, 'Document') if documents[0]

  end

  # @param [Array] doc_ids : array containing all ids of documents that will be bulk deleted.
  def self.bulk_delete(doc_ids)
    documents_toolbox = Document.where(:id => doc_ids)
    documents = []
    Document.transaction do
      documents_toolbox.each do |document|
        documents << document
      end
    end
    Document.delete_all(id: ids)
    journal_delete_creation(documents, documents[0].project_id, User.current.id, 'Document')
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
