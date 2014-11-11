# Author: Nicolas Meylan
# Date: 22.09.14
# Encoding: UTF-8
# File: bulk_edit_manager.rb
module Rorganize
  module Managers
    module BulkEditManager
      include ActiveRecord::ConnectionAdapters::Quoting

      # @param [Array] ids : array of bulk edited object ids.
      # @param [Hash] value_param : hash of {attribute: :new_value}.
      # @param [Project] project : project that belongs to objects.
      # @return [Array] in index 0 there are bulk updated objects, in index 1 there are all created journals.
      def bulk_edit(ids, value_param, project)
        objects_toolbox = self.where(id: ids)
        # As form send all attributes, we drop all attributes except the filled one.
        value_param.delete_if { |_, v| v.eql?('') }
        key = value_param.keys[0]
        value = value_param.values[0]
        if value.eql?('-1')
          value_param[key] = nil
        end
        # Get all changed issues.
        objects = changed_issues(objects_toolbox, value_param)
        value_param[:updated_at] = Time.now
        # Update all changed objects
        self.where(id: objects.collect(&:id)).update_all(value_param)
        # Create journals for this changes
        journals = journal_update_creation(objects, project, User.current.id, self.to_s)
        [objects, journals]
      end

      # @param [Array] objects_toolbox all objects selected(in the toolbox) for the bulk edition.
      # @param [Hash] value_param : hash of {attribute: :new_value}.
      def changed_issues(objects_toolbox, value_param)
        objects = []
        objects_toolbox.each do |issue|
          issue.attributes = value_param
          if issue.changed?
            objects << issue
          end
        end
        objects
      end

      # Bulk delete all objects and their dependencies.
      # @param [Array] object_ids: array of bulk deleted object ids.
      # @param [Project] project
      # @return [Array] array of deleted objects.
      def bulk_delete(object_ids, project)
        objects_toolbox = self.where(id: object_ids)
        objects = []
        objects_toolbox.each do |object|
          objects << object
        end
        self.delete_all(id: object_ids)
        fire_dependent_destroy_triggers(object_ids)
        journal_delete_creation(objects, project.id, User.current.id, self.to_s)
        objects
      end

      # Fire all dependent (after)destroy triggers.
      # @param [Array] object_ids deleted objects ids.
      def fire_dependent_destroy_triggers(object_ids)
        self.included_modules.each do |m|
          root_namespace = m.name && m.name.split('::')[0]
          if root_namespace && root_namespace.eql?('Rorganize') && m.respond_to?(:bulk_delete_dependent)
            m.send(:bulk_delete_dependent, object_ids, self.to_s)
          end
        end
      end

      # Create a journal for a bulk update action.
      # @param [Array] objects : array of updated objects.
      # @param [Project] project.
      # @param [Fixnum] user_id.
      # @param [String] class_name : name of the updated objects' class.
      def journal_update_creation(objects, project, user_id, class_name, journals = nil)
        if objects.any?
          insert = []
          created_at = Time.now.utc.to_formatted_s(:db)
          objects.each do |obj|
            insert << "(#{user_id}, #{obj.id}, '#{class_name}', '#{quote_string(obj.caption[0..127])}', '#{Journal::ACTION_UPDATE}', #{project.id}, '#{created_at}', '#{created_at}')"
          end
          if journals.nil?
            Journal.bulk_insert(insert)
            journals = Journal.where(created_at: created_at)
          end

          journal_detail_insertion(journals, objects)
          if journals.any?
            Rorganize::Managers::NotificationsManager.create_bulk_notification(objects, journals, project, user_id)
          end
          journals
        end
      end

      # Create a journal for bulk delete action.
      # @param [Array] objects : array of deleted objects.
      # @param [Fixnum] project_id.
      # @param [Fixnum] user_id.
      # @param [String] class_name : name of the updated objects' class.
      def journal_delete_creation(objects, project_id, user_id, class_name)
        if objects.any?
          insert = []
          created_at = Time.now.utc.to_formatted_s(:db)
          objects.each do |obj|
            insert << "(#{user_id}, #{obj.id}, '#{class_name}', '#{quote_string(obj.caption[0..127])}', '#{Journal::ACTION_DELETE}', #{project_id}, '#{created_at}', '#{created_at}')"
          end
          Journal.bulk_insert(insert)
        end
      end

      # Create journal details.
      # @param [Array] journals : array of journals.
      # @param [Array] objects : bulk updated objects.
      def journal_detail_insertion(journals, objects)
        excluded_attributes = self.excluded_from_journal_attrs
        objects = build_detail_hash(objects, excluded_attributes)
        insert = []
        journals.each do |journal|
          insertion_hash = Journal.prepare_detail_insertion(self, objects[journal.journalizable_id]).first if objects[journal.journalizable_id]
          if insertion_hash
            old = build_old_value_query_part(insertion_hash)
            new = build_new_value_query_part(insertion_hash)
            insert << "(#{journal.id}, '#{insertion_hash[:property]}', '#{insertion_hash[:property_key]}', '#{old}', '#{new}')"
          end
        end
        perform_insertion(insert)
      end

      def build_new_value_query_part(insertion_hash)
        insertion_hash[:value].is_a?(String) ? quote_string(insertion_hash[:value]) : insertion_hash[:value]
      end

      def build_old_value_query_part(insertion_hash)
        insertion_hash[:old_value].is_a?(String) ? quote_string(insertion_hash[:old_value]) : insertion_hash[:old_value]
      end

      # @param [Array] insert an array of all values.
      def perform_insertion(insert)
        if insert.any?
          sql = "INSERT INTO `journal_details` (`journal_id`, `property`, `property_key`, `old_value`, `value`) VALUES #{insert.join(', ')}"
          JournalDetail.connection.execute(sql)
        end
      end

      # create a hash with following structure : {obj.id: {attr_name: [old_attr_value, new_attr_value]}}
      # E.g : {666: {version_id: [7,8]}}, mean that object 666, has his version_id changed from 7 to 8.
      # @param [Array] objects : bulk updated objects.
      # @param [Hash] properties : attributes that are print in journals details when they changed..
      def build_detail_hash(objects, properties)
        objects.inject({}) do |memo, obj|
          memo[obj.id] = obj.changes.delete_if { |attribute, _| properties.include?(attribute.to_sym) }.inject({}) do |memo_2, (k, v)|
            memo_2[k.to_sym] = v
            memo_2
          end
          memo
        end
      end

    end
  end
end