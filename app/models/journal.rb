# Author: Nicolas Meylan
# Date: 28 juil. 2012
# Encoding: UTF-8
# File: journal.rb

class Journal < ActiveRecord::Base
  include Rorganize::SmartRecords
  ACTION_CREATE = 'created'
  ACTION_UPDATE = 'updated'
  ACTION_DELETE = 'deleted'
  ACTIVITIES_PERIODS = {ONE_DAY: 1, THREE_DAYS: 3, ONE_WEEK: 7, ONE_MONTH: 31}
  has_many :details, :class_name => 'JournalDetail', :dependent => :destroy
  belongs_to :journalized, :polymorphic => true
  belongs_to :issue, foreign_key: 'journalized_id'
  belongs_to :user, :class_name => 'User'
  belongs_to :category
  belongs_to :project
  #Scopes
  scope :fetch_dependencies, -> { eager_load(:details, :project, :user, :journalized) }
  scope :document_activities, ->(document_id) { eager_load([:details, :user]).where(journalized_type: 'Document', journalized_id: document_id) }
  scope :member_activities, ->(member) { where(:user_id => member.user_id, :project_id => member.project_id).order('created_at DESC') }
  scope :activities, ->(journalized_types, date_range, conditions = '1 = 1') {
    includes([:details, :user, :project]).where("journalized_type IN (?) AND #{conditions}", journalized_types).where(created_at: date_range).order('created_at DESC')
  }
  scope :fetch_dependencies_issues, -> { includes(issue: :tracker) }
  scope :fetch_dependencies_categories, -> { includes(:category) }

  def self.activities_eager_load(journalized_types, period, date, conditions)
    periods = ACTIVITIES_PERIODS
    date = date.to_date + 1
    date_range = (date - periods[period.to_sym])..date
    query = self.activities(journalized_types, date_range, conditions)
    query = query.fetch_dependencies_issues if journalized_types.include?('Issue')
    query
  end

  def detail_insertion(updated_attrs, journalized_property, foreign_key_value = {})
    #Remove attributes that won't be considarate in journal update
    updated_attrs.each do |attribute, old_new_value|
      if foreign_key_value[attribute]
        old_value = old_new_value[0] && !foreign_key_value[attribute].nil? ? foreign_key_value[attribute].where(:id => old_new_value[0]).first.caption : nil
        new_value = old_new_value[1] && !old_new_value[1].eql?('') ? foreign_key_value[attribute].where(:id => old_new_value[1]).first.caption : ''
      else
        old_value = old_new_value[0]
        new_value = old_new_value[1]
      end
      JournalDetail.create(:journal_id => self.id, :property => journalized_property[attribute], :property_key => attribute, :old_value => old_value, :value => new_value)
    end
  end


  def self.edit_note(journal_id, owner_id, content)
    journal = Journal.find_by_id(journal_id)
    saved = false
    if journal && journal.user_id.eql?(owner_id)
      saved = journal.update_column(:notes, content)
    end
    journals = Journal.where(:journalized_type => 'Issue', :journalized_id => journal.journalized_id).includes([:details, :user])
    {:saved => saved, :journals => journals}
  end

  def self.delete_note(journal_id, owner_id)
    journal = Journal.find_by_id(journal_id)
    destroyed = false
    if journal && journal.user_id.eql?(owner_id)
      if journal.details.empty?
        destroyed = journal.destroy
      else
        destroyed = journal.update_column(:notes, '')
      end
    end
    journals = Journal.where(:journalized_type => 'Issue', :journalized_id => journal.journalized_id).includes([:details, :user])
    {:destroyed => destroyed, :journals => journals}
  end

  def polymorphic_identifier
    "#{self.journalized_type}_#{self.journalized_id}".to_sym
  end


end
