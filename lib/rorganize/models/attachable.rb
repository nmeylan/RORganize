# Author: Nicolas Meylan
# Date: 04.08.14
# Encoding: UTF-8
# File: attachable.rb
module Rorganize
  module Models
    module Attachable
      #ATTACHMENT METHODS
      def new_attachment_attributes=(attachment_attributes)
        attachment_attributes.each do |attributes|
          attributes['attachable_type'] = self.class.to_s
          attachments.build(attributes)
        end
      end

      def existing_attachment_attributes=(attachment_attributes)
        attachments.reject(&:new_record?).each do |attachment|
          attributes = attachment_attributes[attachment.id.to_s]
          if attributes
            attachment.attributes = attributes
          else
            attachment.delete
          end
        end
      end

      def save(*)
        save_result = super
        add_attachments_error_messages unless self.errors.messages[:attachments].nil?
        save_result
      end

      def add_attachments_error_messages
        self.errors.messages[:attachments].clear
        self.errors.messages[:attachment] = []
        self.attachments.each do |attachment|
          self.errors.messages[:attachment] << build_attachment_error_message(attachment) unless attachment.valid?
        end
      end

      def build_attachment_error_message(attachment)
        "#{attachment.file_file_name} #{attachment.errors.messages.values.flatten.uniq.join('. Attachment ')}"
      end

      def save_attachments
        attachments.each do |attachment|
          attachment.save
        end
      end

      class << self
        def bulk_delete_dependent(attachable_ids, class_name)
          Attachment.destroy_all(attachable_id: attachable_ids, attachable_type: class_name)
        end
      end
    end
  end
end