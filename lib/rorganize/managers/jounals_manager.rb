#Author : Nicolas Meylan
#Date: 19 juil. 2013
#Encoding: UTF-8
#File: journalizable_record_callback

module Rorganize
  module Managers
    module JounalsManager
      module ClassMethods
        def exclude_attributes_from_journal(*properties)
          @excluded_from_journal_attrs = [:created_at, :updated_at] | properties
        end

        def excluded_from_journal_attrs
          @excluded_from_journal_attrs ||= []
        end
      end

      def create_journal
        project_id = self.respond_to?('project_id') ? self.project_id : nil
        action = Journal::ACTION_CREATE
        insert_journal!(action, project_id)
      end

      def update_journal
        project_id = self.respond_to?('project_id') ? self.project_id : nil
        action = Journal::ACTION_UPDATE
        updated_journalizable_attributes = updated_attributes(self.class.excluded_from_journal_attrs)
        #Create journalizable only if a relevant attribute has been updated
        if updated_journalizable_attributes.any?
          journal = insert_journal!(action, project_id)
          journal.detail_insertion(self.class, updated_journalizable_attributes)
        end
      end

      def updated_attributes(journalizable_attributes)
        self.changes.delete_if do |attribute, _|
          journalizable_attributes.include?(attribute.to_sym)
        end.inject({}) do |memo, (k, v)|
          memo[k.to_sym] = v
          memo
        end
      end

      def destroy_journal
        action = Journal::ACTION_DELETE
        project_id = self.respond_to?('project_id') ? self.project_id : nil
        insert_journal!(action, project_id)
      end

      def insert_journal!(action, project_id)
        Journal.create(user_id: User.current.id,
                       journalizable_id: self.id,
                       journalizable_type: self.class.to_s,
                       journalizable_identifier: self.caption[0..127],
                       notes: '',
                       action_type: action,
                       project_id: project_id)
      end
    end
  end
end