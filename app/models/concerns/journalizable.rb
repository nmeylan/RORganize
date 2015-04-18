# Author: Nicolas Meylan
# Date: 04.08.14
# Encoding: UTF-8
# File: journalizable.rb

module Journalizable
  include Rorganize::Managers::JounalsManager
  extend ActiveSupport::Concern

  included do |base|
    base.extend Rorganize::Managers::JounalsManager::ClassMethods
    has_many :journals, -> { where journalizable_type: base }, as: :journalizable, dependent: :destroy
    after_create :create_journal
    after_update :update_journal
    after_destroy :destroy_journal
  end

  class << self
    def bulk_delete_dependent(journalizable_ids, class_name)
      journals = Journal.where(journalizable_id: journalizable_ids, journalizable_type: class_name)
      JournalDetail.delete_all(journal_id: journals.collect(&:id))
      journals.delete_all
    end
  end
end