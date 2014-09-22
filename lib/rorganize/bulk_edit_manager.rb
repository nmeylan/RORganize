# Author: Nicolas Meylan
# Date: 22.09.14
# Encoding: UTF-8
# File: bulk_edit_manager.rb
module Rorganize
  module BulkEditManager
    include ActiveRecord::ConnectionAdapters::Quoting
    extend ActiveSupport::Concern
    included do |base|

    end

    def journal_update_creation(objects, project_id, user_id, klazz)
      if objects.any?
        insert = []
        created_at = Time.now.utc.to_formatted_s(:db)
        objects.each do |obj|
          insert << "(#{user_id}, #{obj.id}, '#{klazz}', '#{quote_string(obj.caption[0..127])}', '#{Journal::ACTION_UPDATE}', #{project_id}, '#{created_at}', '#{created_at}')"
        end
        sql = "INSERT INTO `journals` (`user_id`, `journalizable_id`, `journalizable_type`, `journalizable_identifier`, `action_type`, `project_id`, `created_at`, `updated_at`) VALUES #{insert.join(', ')}"
        Journal.connection.execute(sql)
        journals = Journal.where(created_at: created_at)
        journal_detail_insertion(journals, objects[0])
        if journals.any?
          Rorganize::NotificationsManager.create_bulk_notification(objects, journals, project_id, user_id)
        end
        journals
      end
    end

    def journal_delete_creation(objects, project_id, user_id, klazz)
      if objects.any?
        insert = []
        created_at = Time.now.utc.to_formatted_s(:db)
        objects.each do |obj|
          insert << "(#{user_id}, #{obj.id}, '#{klazz}', '#{quote_string(obj.caption[0..127])}', '#{Journal::ACTION_DELETE}', #{project_id}, '#{created_at}', '#{created_at}')"
        end
        sql = "INSERT INTO `journals` (`user_id`, `journalizable_id`, `journalizable_type`, `journalizable_identifier`, `action_type`, `project_id`, `created_at`, `updated_at`) VALUES #{insert.join(', ')}"
        Journal.connection.execute(sql)
      end
    end

    def journal_detail_insertion(journals, obj)
      properties = self.journalizable_properties
      foreign_keys = self.foreign_keys
      journalizable_attributes = properties.keys
      updated_journalizable_attributes = obj.changes.delete_if { |attribute, _| !journalizable_attributes.include?(attribute.to_sym) }.inject({}) { |memo, (k, v)| memo[k.to_sym] = v; memo }

      insertion_hash = Journal.prepare_detail_insertion(updated_journalizable_attributes, properties, foreign_keys).first
      insert = []
      if insertion_hash
        journals.each do |journal|
          insert << "(#{journal.id}, '#{insertion_hash[:property]}', '#{insertion_hash[:property_key]}', '#{insertion_hash[:old_value]}', '#{insertion_hash[:value]}')"
        end
        sql = "INSERT INTO `journal_details` (`journal_id`, `property`, `property_key`, `old_value`, `value`) VALUES #{insert.join(', ')}"
        JournalDetail.connection.execute(sql)
      end
    end


  end
end