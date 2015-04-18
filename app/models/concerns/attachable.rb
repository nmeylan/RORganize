# Author: Nicolas Meylan
# Date: 04.08.14
# Encoding: UTF-8
# File: attachable.rb
module Attachable
  #ATTACHMENT METHODS
  def new_attachment_attributes=(attachment_attributes)
    attachment_attributes.each do |attributes|
      attributes['attachable_type'] = self.class.to_s
      attachments.build(attributes)
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