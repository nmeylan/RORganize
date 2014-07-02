#Author : Nicolas Meylan
#Date: 19 juil. 2013 
#Encoding: UTF-8
#File: journalized_record_callback

module Rorganize
  module JournalizedRecordCallback
    class << self
      def included(base)
        base.extend ClassMethods
      end
    end
    
    module ClassMethods
      def assign_journalized_properties(properties)
        @journalized_properties = properties
      end
      def journalized_properties
        @journalized_properties
      end
      def assign_foreign_keys(foreign_key)
        @foreign_keys = foreign_key
      end
      def foreign_keys
        @foreign_keys
      end
      
      def assign_journalized_icon(asset_path = '')
        @journalized_icon = asset_path
      end
      def journalized_icon
        @journalized_icon
      end
    end
    def create_journal
      p_id = self.respond_to?('project_id') ? self.project_id : nil
      Journal.create(:user_id => User.current.id,
        :journalized_id => self.id,
        :journalized_type => self.class.to_s,
        :journalized_identifier => self.caption,
        :notes => '',
        :action_type => 'created',
        :project_id => p_id)
    end
    def update_journal
      p_id = self.respond_to?('project_id') ? self.project_id : nil
      notes = self.respond_to?('notes') && !self.notes.nil? ? self.notes : ''
      properties =  self.class.journalized_properties
      foreign_keys = self.class.foreign_keys
      journalized_attributes = properties.keys
      updated_journalized_attributes = self.changes.delete_if{|attribute, value| !journalized_attributes.include?(attribute)}
      #Create journal only if a relevant attribute has been updated
      if updated_journalized_attributes.any? || (!notes.nil? && !notes.eql?(''))
        journal = Journal.create(:user_id => User.current.id,
          :journalized_id => self.id,
          :journalized_type => self.class.to_s,
          :journalized_identifier => self.caption,
          :notes => notes,
          :action_type => 'updated',
          :project_id => p_id)
        journal.detail_insertion(updated_journalized_attributes, properties, foreign_keys)
      end
    end
    def destroy_journal
      p self
      p_id = self.respond_to?('project_id') ? self.project_id : nil
      Journal.create(:user_id => User.current.id,
        :journalized_id => self.id,
        :journalized_type => self.class.to_s,
        :journalized_identifier => self.caption,
        :notes => '',
        :action_type => 'deleted',
        :project_id => p_id)
    end

  end
end