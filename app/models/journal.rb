# Author: Nicolas Meylan
# Date: 28 juil. 2012
# Encoding: UTF-8
# File: journalizable.rb

class Journal < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  include Rorganize::Managers::NotificationsManager
  ACTION_CREATE = 'created'
  ACTION_UPDATE = 'updated'
  ACTION_DELETE = 'deleted'
  ACTIVITIES_PERIODS = {ONE_DAY: 1, THREE_DAYS: 3, ONE_WEEK: 7, ONE_MONTH: 31}
  has_many :details, class_name: 'JournalDetail', dependent: :destroy
  belongs_to :journalizable, polymorphic: true
  belongs_to :issue, foreign_key: 'journalizable_id'
  belongs_to :document, foreign_key: 'journalizable_id'
  belongs_to :user, class_name: 'User'
  belongs_to :category
  belongs_to :project
  #Scopes
  scope :fetch_dependencies, -> { includes(:details, :project, :user, :journalizable) }
  scope :document_activities, ->(document_id) { includes([:details, user: :avatar]).where(journalizable_type: 'Document', journalizable_id: document_id) }
  scope :issue_activities, ->(issuer_id) { includes([:details, user: :avatar]).where(journalizable_type: 'Issue', journalizable_id: issuer_id) }
  scope :member_activities, ->(member) { where(user_id: member.user_id, project_id: member.project_id).order('created_at DESC') }
  scope :activities, ->(journalizable_types, date_range, days, conditions = '1 = 1') {
    includes([:details, :project, user: :avatar]).where("journalizable_type IN (?) AND journals.created_at BETWEEN ? AND ?", journalizable_types, date_range.first, date_range.last).where(conditions).order('journals.created_at DESC').limit(days * 1000)
  }
  scope :fetch_dependencies_issues, -> { includes(issue: :tracker) }
  scope :fetch_dependencies_documents, -> { includes(:document) }
  scope :fetch_dependencies_categories, -> { includes(:category) }

  def self.activities_eager_load(journalizable_types, period, date, conditions)
    periods = ACTIVITIES_PERIODS
    date = date.to_date + 1
    days = periods[period.to_sym]
    date_range = (date - days)..date
    query = self.activities(journalizable_types, date_range, days, conditions)
    query = query.fetch_dependencies_issues if journalizable_types.include?('Issue')
    query = query.fetch_dependencies_documents if journalizable_types.include?('Document')
    query
  end

  # @param [Hash] updated_attr : a hash containing all updated attributes with their old and new value (e.g {attr_name: [old_value, new_value]}).
  # @param [Hash] journalizable_property : a hash with the following structure : {attr_name: 'Attribute name'}
  # @param [Hash] foreign_key_value : a hash with following structure : {attr_name: foreign_key}
  def detail_insertion(updated_attrs, journalizable_property, foreign_key_value = {})
    array = Journal.prepare_detail_insertion(updated_attrs, journalizable_property, foreign_key_value)
    array.each do |hash|
      JournalDetail.create(journal_id: self.id, property: hash[:property], property_key: hash[:property_key], old_value: hash[:old_value], value: hash[:value])
    end
  end

  def self.prepare_detail_insertion(updated_attrs, journalizable_property, foreign_key_value = {})
    return_array = []
    updated_attrs.each do |attribute, old_new_value|
      if foreign_key_value && foreign_key_value[attribute]
        old_value = old_new_value[0] && !foreign_key_value[attribute].nil? ? foreign_key_value[attribute].where(id: old_new_value[0]).first.caption : nil
        new_value = old_new_value[1] && !old_new_value[1].eql?('') ? foreign_key_value[attribute].where(id: old_new_value[1]).first.caption : ''
      else
        old_value = old_new_value[0]
        new_value = old_new_value[1]
      end
      return_array << {property: journalizable_property[attribute], property_key: attribute, old_value: old_value, value: new_value}
    end
    return_array
  end


  def polymorphic_identifier
    "#{self.journalizable_type}_#{self.journalizable_id}".to_sym
  end

  # Bulk insert journals in a single query.
  # @param [Array] insert : an array of sql values to insert.
  def self.bulk_insert(insert)
    sql = "INSERT INTO `journals` (`user_id`, `journalizable_id`, `journalizable_type`, `journalizable_identifier`, `action_type`, `project_id`, `created_at`, `updated_at`) VALUES #{insert.join(', ')}"
    Journal.connection.execute(sql)
  end


end
