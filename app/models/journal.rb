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
  scope :fetch_dependencies, -> { fetch_dependencies_method }

  scope :journalizable_activities, ->(journalizable_id, journalizable_type) { journalizable_activities_method(journalizable_id, journalizable_type) }

  scope :member_activities, ->(member) { member_activities_method(member) }

  scope :activities, ->(journalizable_types, date_range, days, conditions = '1 = 1') {
    activities_method(conditions, date_range, days, journalizable_types)
  }

  #Scopes methods
  # This scope method give all activities.
  # @param [String] conditions.
  # @param [Range] date_range.
  # @param [Numeric] days.
  # @param [Array] journalizable_types : all journalizable types. e.g [Issue, Document, Member].
  def self.activities_method(conditions, date_range, days, journalizable_types)
    includes([:details, :project, user: :avatar]).
        where("journalizable_type IN (?) AND DATE_FORMAT(journals.created_at, '%Y-%m-%d') BETWEEN ? AND ?",
              journalizable_types, date_range.first, date_range.last).
        where(conditions).
        order('journals.created_at DESC').
        limit(days * 1000)
  end

  def self.member_activities_method(member)
    where(user_id: member.user_id, project_id: member.project_id).
        order('created_at DESC')
  end

  def self.journalizable_activities_method(journalizable_id, journalizable_type)
    includes([:details, user: :avatar]).where(journalizable_type: journalizable_type, journalizable_id: journalizable_id)
  end

  def self.fetch_dependencies_method
    includes(:details, :project, :user, :journalizable)
  end

  # Methods

  def self.activities_eager_load(journalizable_types, period, date, conditions)
    periods = ACTIVITIES_PERIODS
    date = date.to_date
    days = periods[period.to_sym]
    date_range = (date - days)..date
    query = self.activities(journalizable_types, date_range, days, conditions)
    query = query.preload(:journalizable)
    query
  end

  # @param [ActiveRecord::Base] klazz : the class that is updated.
  # @param [Hash] updated_attrs : a hash containing all updated attributes with their old and new value (e.g {attr_name: [old_value, new_value]}).
  def detail_insertion(klazz, updated_attrs)
    array = Journal.prepare_detail_insertion(klazz, updated_attrs)
    array.each do |hash|
      JournalDetail.create(journal_id: self.id, property: hash[:property], property_key: hash[:property_key], old_value: hash[:old_value], value: hash[:value])
    end
  end

  # @param [ActiveRecord::Base] klazz : the class that is updated.
  # @param [Hash] updated_attrs : a hash containing all updated attributes with their old and new value (e.g {attr_name: [old_value, new_value]}).
  def self.prepare_detail_insertion(klazz, updated_attrs)
    return_array = []
    foreign_keys_hash = klazz.foreign_keys
    updated_attrs.each do |attribute, old_new_value|
      if foreign_keys_hash[attribute.to_sym]
        old_value = foreign_attribute_value(foreign_keys_hash[attribute.to_sym], old_new_value[0])
        new_value = foreign_attribute_value(foreign_keys_hash[attribute.to_sym], old_new_value[1])
      else
        old_value = old_new_value[0]
        new_value = old_new_value[1]
      end
      return_array << {property: make_attribute_readable(attribute), property_key: attribute, old_value: old_value, value: new_value}
    end
    return_array
  end

  # Make the attribute name more readable (remove id, underscore then capitalize).
  # @param [Symbol] attribute that was updated.
  def self.make_attribute_readable(attribute)
    attribute.to_s.tr('_', ' ').gsub('id','').capitalize
  end

  def self.foreign_attribute_value(association, value)
    foreign_attribute = association.find_by_id(value)
    foreign_attribute.caption unless foreign_attribute.nil?
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
