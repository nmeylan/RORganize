# Author: Nicolas Meylan
# Date: 20.09.14
# Encoding: UTF-8
# File: notifiable.rb

module Rorganize
  module Notifiable
    extend ActiveSupport::Concern
    included do |base|
      has_many :notifications, -> { where(notifiable_type: base) }, as: :notifiable, dependent: :destroy
    end

  end
end