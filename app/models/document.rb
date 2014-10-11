# Author: Nicolas Meylan
# Date: 06 avri. 2013
# Encoding: UTF-8
# File: document.rb
class Document < ActiveRecord::Base
  include Rorganize::Models::Journalizable
  include Rorganize::Models::SmartRecords
  include Rorganize::Models::Attachable::AttachmentType
  include Rorganize::Models::Commentable
  include Rorganize::Models::Watchable
  include Rorganize::Models::Notifiable
  extend Rorganize::Managers::BulkEditManager
  #Class variables
  assign_journalizable_properties({name: 'Name', category_id: 'Category', version_id: 'Version'})
  assign_foreign_keys({category_id: Category, version_id: Version})
  #Relations
  belongs_to :version
  belongs_to :category
  belongs_to :project
  #Validators
  validates :name, presence: true, length: 2..255
  #triggers
  after_update :save_attachments
  #Scopes
  scope :fetch_dependencies, -> { includes([:version, :category, :attachments]) }
  #methods

  def caption
    self.name
  end

  def author
    Journal.find_by_action_type_and_journalizable_id_and_journalizable_type('created', self.id, self.class.to_s).user
  end

  def self.permit_attributes
    [:name, :description, :version_id, :category_id, {new_attachment_attributes: Attachment.permit_attributes}, {edit_attachment_attributes: Attachment.permit_attributes}]
  end

  def self.permit_bulk_edit_values
    [:version_id, :category_id]
  end

  # @return [Array] with all attribute that can be filtered.
  def self.filtered_attributes
    unused_attributes = %w(Project Description)
    attrs = Document.attributes_formalized_names.delete_if { |attribute| unused_attributes.include?(attribute) }
    attrs.map { |attribute| [attribute, attribute.gsub(/\s/, '_').downcase] }
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
