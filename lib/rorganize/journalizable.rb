# Author: Nicolas Meylan
# Date: 04.08.14
# Encoding: UTF-8
# File: journalizable.rb

module Rorganize
  module Journalizable
    include Rorganize::JounalsManager
    extend ActiveSupport::Concern
    included do |base|
      has_many :journals, -> { where :journalizable_type => base }, :as => :journalizable, :dependent => :destroy
      after_create :create_journal
      after_update :update_journal
      after_destroy :destroy_journal
    end
  end
end