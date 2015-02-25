# Author: Nicolas Meylan
# Date: 04.08.14
# Encoding: UTF-8
# File: attachment_remove.rb
module Rorganize
  module Models
    module Attachable
      module AttachmentType
        include Rorganize::Models::Attachable
        extend ActiveSupport::Concern
        included do |base|
          has_many :attachments, -> { where attachable_type: base }, class_name: 'Attachment', foreign_key: :attachable_id, dependent: :destroy
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
      end
    end
  end
end