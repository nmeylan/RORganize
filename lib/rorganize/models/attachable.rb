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