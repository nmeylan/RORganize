# Author: Nicolas Meylan
# Date: 04.08.14
# Encoding: UTF-8
# File: attachable.rb
module Rorganize
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
        attachment.save(:validation => false)
      end
    end
  end
end