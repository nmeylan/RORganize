#Author : Nicolas Meylan
#Date: 19 juil. 2013 
#Encoding: UTF-8
#File: journalizable_record_callback

module Rorganize
  module Managers
  module JounalsManager
    module ClassMethods
      def init_journals_manager
        @foreign_keys = {}
      end

      def assign_journalizable_properties(properties)
        @journalizable_properties = properties
      end

      def journalizable_properties
        @journalizable_properties
      end

      def assign_foreign_keys(foreign_keys)
        @foreign_keys = foreign_keys
      end

      def foreign_keys
        @foreign_keys
      end
    end

    def self.included(base)
      base.extend ClassMethods
      base.init_journals_manager
    end

    def create_journal
      p_id = self.respond_to?('project_id') ? self.project_id : nil
      Journal.create(:user_id => User.current.id,
                     :journalizable_id => self.id,
                     :journalizable_type => self.class.to_s,
                     :journalizable_identifier => self.caption[0..127],
                     :notes => '',
                     :action_type => Journal::ACTION_CREATE,
                     :project_id => p_id)
    end

    def update_journal
      p_id = self.respond_to?('project_id') ? self.project_id : nil
      notes = self.respond_to?('notes') && !self.notes.nil? ? self.notes : ''
      properties = self.class.journalizable_properties
      foreign_keys = self.class.foreign_keys
      journalizable_attributes = properties.keys
      updated_journalizable_attributes = self.changes.delete_if { |attribute, _| !journalizable_attributes.include?(attribute.to_sym) }.inject({}) { |memo, (k, v)| memo[k.to_sym] = v; memo }
      #Create journalizable only if a relevant attribute has been updated
      if updated_journalizable_attributes.any? || (!notes.nil? && !notes.eql?(''))
        journal = Journal.create(:user_id => User.current.id,
                                 :journalizable_id => self.id,
                                 :journalizable_type => self.class.to_s,
                                 :journalizable_identifier => self.caption[0..127],
                                 :notes => notes,
                                 :action_type => Journal::ACTION_UPDATE,
                                 :project_id => p_id)
        journal.detail_insertion(updated_journalizable_attributes, properties, foreign_keys)
      end
    end

    def destroy_journal
      p_id = self.respond_to?('project_id') ? self.project_id : nil
      Journal.create(:user_id => User.current.id,
                     :journalizable_id => self.id,
                     :journalizable_type => self.class.to_s,
                     :journalizable_identifier => self.caption[0..127],
                     :notes => '',
                     :action_type => Journal::ACTION_DELETE,
                     :project_id => p_id)
    end
  end
end
end