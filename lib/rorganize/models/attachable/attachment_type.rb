# Author: Nicolas Meylan
# Date: 04.08.14
# Encoding: UTF-8
# File: attachment.rb
module Rorganize
  module Models
    module Attachable
      module AttachmentType
        include Rorganize::Models::Attachable
        extend ActiveSupport::Concern
        included do |base|
          has_many :attachments, -> { where attachable_type: base }, class_name: 'Attachment', foreign_key: :attachable_id, :dependent => :destroy
        end
      end
    end
  end
end