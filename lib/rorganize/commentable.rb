# Author: Nicolas Meylan
# Date: 27.07.14
# Encoding: UTF-8
# File: commentable.rb
module Rorganize
  module Commentable
    extend ActiveSupport::Concern
    included do |base|
      has_many :comments, -> { (where commentable_type: base).eager_load(:project, :author) }, as: :commentable, dependent: :destroy
    end

    def commented?
      self.comments_count > 0
    end

  end
end