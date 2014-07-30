# Author: Nicolas Meylan
# Date: 27.07.14
# Encoding: UTF-8
# File: comments_manager.rb
module Rorganize
  module CommentsManager
    extend ActiveSupport::Concern
    included do |base|
      p base
      has_many :comments, -> { (where commentable_type: base).eager_load(:project, :author) }, as: :commentable, dependent: :destroy
    end

  end
end