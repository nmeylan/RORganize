# Author: Nicolas Meylan
# Date: 04.08.14
# Encoding: UTF-8
# File: avatar.rb
module Rorganize
  module Models
    module Attachable
      module AvatarType
        include Rorganize::Models::Attachable
        extend ActiveSupport::Concern
        included do |base|
          has_one :avatar, -> { where attachable_type: base }, foreign_key: :attachable_id, dependent: :destroy
        end
      end
    end
  end
end