# Author: Nicolas Meylan
# Date: 04.08.14
# Encoding: UTF-8
# File: avatar.rb
module Attachable::AvatarType
  include Attachable
  extend ActiveSupport::Concern
  included do |base|
    has_one :avatar, -> { where attachable_type: base }, foreign_key: :attachable_id, dependent: :destroy
  end

  def save_avatar
    save_result = self.avatar.save
    add_attachments_error_messages
    save_result
  end

  def add_attachments_error_messages
    self.errors.messages[:avatar] = []
    self.errors.messages[:avatar] << build_attachment_error_message(avatar) unless self.avatar.valid?
  end

  def build_attachment_error_message(avatar)
    "#{avatar.file_file_name} #{avatar.errors.messages.values.flatten.uniq.join('. Attachment ')}"
  end
end